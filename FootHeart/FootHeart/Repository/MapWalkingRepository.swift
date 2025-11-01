//
//  MapWalkingRepository.swift
//  FootHeart
//
//  Created by Jupond on 10/30/25.
//
import Foundation
import CoreMotion
import CoreLocation
import Combine

class MapWalkingRepository {
    
    private let movementSystem = HybridStepTracker()
    private let mapSubject = PassthroughSubject<MapWalkingModel, Never>()
    private let calculator = StepCalorieCalculator()
    
    private var mapWalkingData: MapWalkingModel
    private var startTime: Date?
    private var startSteps: Int = 0
    private var startDistance: Double = 0
    private var pausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    private var isTracking: Bool = false
    private var bmiModel: BMIModel?
    
    // 움직임 기반 활동 시간 추적
    private var lastSteps: Int = 0
    private var lastDistance: Double = 0
    private var lastMovementTime: Date?
    private var activeDuration: TimeInterval = 0  // 실제 활동 시간만 누적
    private var lastUpdateTime: Date?
    
    init() {
        self.mapWalkingData = MapWalkingModel(
            date: Date(),
            steps: 0,
            path: [],
            kcal: 0.0,
            walkMode: .WALK,
            distance: 0.0,
            duration: 0,
            currentSpeed: 0
        )
        
        setupMovementSystem()
    }
    
    private func setupMovementSystem() {
        movementSystem.onWalkingUpdate = { [weak self] walkingModel in
            guard let self = self,
                  let startTime = self.startTime,
                  self.isTracking else {
                return
            }
            
            // 일시정지 중이면 업데이트 안 함
            if self.pauseStartTime != nil {
                print("MapWalkingRepository, setupMovementSystem // 일시정지 중")
                return
            }
            
            let currentSteps = walkingModel.steps - self.startSteps
            let currentDistance = walkingModel.distance - self.startDistance
            let now = Date()
            
            // 움직임 감지 (걸음 수 또는 거리가 증가했는지 확인)
            let hasMovement = currentSteps > self.lastSteps || currentDistance > self.lastDistance
            
            if hasMovement {
                // 움직임이 있으면 활동 시간 증가
                if let lastUpdate = self.lastUpdateTime {
                    let interval = now.timeIntervalSince(lastUpdate)
                    
                    // 최대 10초까지만 인정 (GPS 튀는 경우 방지)
                    if interval <= 10.0 {
                        self.activeDuration += interval
                    }
                }
                
                self.lastSteps = currentSteps
                self.lastDistance = currentDistance
                self.lastMovementTime = now
            }
            
            self.lastUpdateTime = now
            
            // 총 경과 시간 계산
            let totalDuration = Date().timeIntervalSince(startTime) - self.pausedDuration
            
            // 칼로리 계산 (활동 시간만 사용)
            var kcal = 0.0
            if let bmiModel = self.bmiModel, currentSteps > 0, self.activeDuration > 0 {
                let tempModel = MapWalkingModel(
                    date: startTime,
                    steps: currentSteps,
                    path: walkingModel.path,
                    kcal: 0,
                    walkMode: self.mapWalkingData.walkMode,
                    distance: currentDistance,
                    duration: self.activeDuration,  // 실제 활동 시간만 사용
                    currentSpeed: walkingModel.currentSpeed
                )
                
                kcal = self.calculator.calculateCaloriesWithRealSpeed(
                    mapWalkingModel: tempModel,
                    model: bmiModel
                )
            }
            
            // 최종 모델 생성
            let mapModel = MapWalkingModel(
                date: startTime,
                steps: currentSteps,
                path: walkingModel.path,
                kcal: kcal,
                walkMode: self.mapWalkingData.walkMode,
                distance: currentDistance,
                duration: totalDuration,  // UI에는 총 시간 표시
                currentSpeed: walkingModel.currentSpeed
            )
            
            self.mapWalkingData = mapModel
            self.mapSubject.send(mapModel)
            
            print("MapWalkingRepository, setupMovementSystem // steps=\(currentSteps), totalTime=\(Int(totalDuration))s, activeTime=\(Int(self.activeDuration))s, kcal=\(String(format: "%.1f", kcal)), moved=\(hasMovement)")
        }
    }
    
    func setBMIModel(_ model: BMIModel) {
        self.bmiModel = model
    }
    
    func start(mode: WalkMode) -> AnyPublisher<MapWalkingModel, Never> {
        movementSystem.startTracking()
        isTracking = true
        
        startTime = Date()
        let currentData = movementSystem.getCurrentStepData()
        startSteps = currentData.steps
        startDistance = currentData.distance
        
        pausedDuration = 0
        pauseStartTime = nil
        
        // 움직임 추적 초기화
        lastSteps = 0
        lastDistance = 0
        lastMovementTime = Date()
        lastUpdateTime = Date()
        activeDuration = 0
        
        mapWalkingData = MapWalkingModel(
            date: Date(),
            steps: 0,
            path: [],
            kcal: 0.0,
            walkMode: mode,
            distance: 0.0,
            duration: 0,
            currentSpeed: 0
        )
        
        print("MapWalkingRepository, start // 운동 시작")
        mapSubject.send(mapWalkingData)
        return mapSubject.eraseToAnyPublisher()
    }
    
    func pause() {
        guard isTracking else {
            print("MapWalkingRepository, pause // 운동 중이 아님")
            return
        }
        
        pauseStartTime = Date()
        print("MapWalkingRepository, pause // 운동 일시정지")
    }
    
    func resume() {
        guard isTracking else {
            print("MapWalkingRepository, resume // 운동 중이 아님")
            return
        }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
        lastMovementTime = Date()
        lastUpdateTime = Date()  // 재개 시 업데이트 시간 리셋
        print("MapWalkingRepository, resume // 운동 재개")
    }
    
    func stop() -> MapWalkingModel {
        guard isTracking else {
            print("MapWalkingRepository, stop // 운동 중이 아님")
            return mapWalkingData
        }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        
        if let startTime = startTime {
            let totalDuration = Date().timeIntervalSince(startTime) - pausedDuration
            
            // 최종 칼로리 재계산 (활동 시간 사용)
            var kcal = 0.0
            if let bmiModel = self.bmiModel, mapWalkingData.steps > 0, activeDuration > 0 {
                let tempModel = MapWalkingModel(
                    date: startTime,
                    steps: mapWalkingData.steps,
                    path: mapWalkingData.path,
                    kcal: 0,
                    walkMode: mapWalkingData.walkMode,
                    distance: mapWalkingData.distance,
                    duration: activeDuration,  // 활동 시간 사용
                    currentSpeed: 0
                )
                kcal = calculator.calculateCaloriesWithRealSpeed(
                    mapWalkingModel: tempModel,
                    model: bmiModel
                )
            }
            
            let finalModel = MapWalkingModel(
                date: startTime,
                steps: mapWalkingData.steps,
                path: mapWalkingData.path,
                kcal: kcal,
                walkMode: mapWalkingData.walkMode,
                distance: mapWalkingData.distance,
                duration: totalDuration,
                currentSpeed: 0
            )
            
            mapWalkingData = finalModel
            
            print("MapWalkingRepository, stop // 운동 종료 - 총시간: \(Int(totalDuration))s, 활동시간: \(Int(activeDuration))s, kcal: \(String(format: "%.1f", kcal))")
        }
        
        movementSystem.stopTracking()
        isTracking = false
        
        return mapWalkingData
    }
    
    func reset() {
        isTracking = false
        startTime = nil
        startSteps = 0
        startDistance = 0
        pausedDuration = 0
        pauseStartTime = nil
        
        lastSteps = 0
        lastDistance = 0
        lastMovementTime = nil
        lastUpdateTime = nil
        activeDuration = 0
        
        mapWalkingData = MapWalkingModel(
            date: Date(),
            steps: 0,
            path: [],
            kcal: 0.0,
            walkMode: .WALK,
            distance: 0.0,
            duration: 0,
            currentSpeed: 0
        )
        
        print("MapWalkingRepository, reset // 운동 데이터 리셋")
    }
    
    func getCurrentData() -> MapWalkingModel {
        return mapWalkingData
    }
}
