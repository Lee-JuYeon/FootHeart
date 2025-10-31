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
    
    // ✅ 움직임 추적용
    private var lastSteps: Int = 0
    private var lastDistance: Double = 0
    private var lastMovementTime: Date?
    private var inactiveDuration: TimeInterval = 0
    private var lastInactiveCheckTime: Date?
    private var movementCheckTimer: Timer?
    
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
            
            // 일시정지 중이면 칼로리 계산하지 않음
            if self.pauseStartTime != nil {
                print("MapWalkingRepository, setupMovementSystem // 일시정지 중 - 칼로리 계산 생략")
                return
            }
            
            let currentSteps = walkingModel.steps - self.startSteps
            let currentDistance = walkingModel.distance - self.startDistance
            
            // 실제 활동 시간 계산
            let totalDuration = Date().timeIntervalSince(startTime) - self.pausedDuration
            let activeDuration = totalDuration - self.inactiveDuration
            
            // 칼로리 계산 (활동 시간만 사용)
            var kcal = 0.0
            if let bmiModel = self.bmiModel, currentSteps > 0 {
                let tempModel = MapWalkingModel(
                    date: startTime,
                    steps: currentSteps,
                    path: walkingModel.path,
                    kcal: 0,
                    walkMode: self.mapWalkingData.walkMode,
                    distance: currentDistance,
                    duration: activeDuration,  // 활동 시간만 사용
                    currentSpeed: walkingModel.currentSpeed
                )
                kcal = self.calculator.calculateCaloriesWithRealSpeed(
                    mapWalkingModel: tempModel,
                    model: bmiModel
                )
            }
            
            let mapModel = MapWalkingModel(
                date: startTime,
                steps: currentSteps,
                path: walkingModel.path,
                kcal: kcal,
                walkMode: self.mapWalkingData.walkMode,
                distance: currentDistance,
                duration: totalDuration,
                currentSpeed: walkingModel.currentSpeed
            )
            
            self.mapWalkingData = mapModel
            self.mapSubject.send(mapModel)
            
            print("MapWalkingRepository, setupMovementSystem // steps=\(currentSteps), totalDuration=\(Int(totalDuration))s, activeDuration=\(Int(activeDuration))s, kcal=\(String(format: "%.1f", kcal))")
        }
    }
    // ✅ 움직임 체크 타이머 시작
    private func startMovementCheckTimer() {
        stopMovementCheckTimer()
        
        lastInactiveCheckTime = Date()
        
        movementCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  self.isTracking,
                  self.pauseStartTime == nil else {
                return
            }
            
            // ✅ 10초 이상 움직임 없으면 inactive 시간 증가
            if let lastMovement = self.lastMovementTime,
               let lastCheck = self.lastInactiveCheckTime {
                let timeSinceLastMovement = Date().timeIntervalSince(lastMovement)
                
                if timeSinceLastMovement >= 10.0 {
                    // 10초 이상 움직임 없음
                    let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
                    self.inactiveDuration += timeSinceLastCheck
                    print("🛑 비활동 시간 증가: +\(Int(timeSinceLastCheck))s, 총 비활동=\(Int(self.inactiveDuration))s")
                }
            }
            
            self.lastInactiveCheckTime = Date()
        }
    }
    
    // ✅ 움직임 체크 타이머 중지
    private func stopMovementCheckTimer() {
        movementCheckTimer?.invalidate()
        movementCheckTimer = nil
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
        
        // ✅ 움직임 추적 초기화
        lastSteps = 0
        lastDistance = 0
        lastMovementTime = Date()
        inactiveDuration = 0
        lastInactiveCheckTime = Date()
        
        // ✅ 움직임 체크 타이머 시작
        startMovementCheckTimer()
        
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
        
        print("🟢 운동 시작")
        mapSubject.send(mapWalkingData)
        return mapSubject.eraseToAnyPublisher()
    }
    
    func pause() {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return
        }
        
        pauseStartTime = Date()
        print("⏸️ 운동 일시정지")
    }
    
    func resume() {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return
        }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
        lastInactiveCheckTime = Date()  // ✅ 재개 시 체크 시간 리셋
        print("▶️ 운동 재개")
    }
    
    func stop() -> MapWalkingModel {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return mapWalkingData
        }
        
        // ✅ 타이머 중지
        stopMovementCheckTimer()
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        
        if let startTime = startTime {
            let totalDuration = Date().timeIntervalSince(startTime) - pausedDuration
            let activeDuration = totalDuration - inactiveDuration
            
            // ✅ 최종 칼로리 재계산 (활동 시간만 사용)
            var kcal = 0.0
            if let bmiModel = self.bmiModel, mapWalkingData.steps > 0 {
                let tempModel = MapWalkingModel(
                    date: startTime,
                    steps: mapWalkingData.steps,
                    path: mapWalkingData.path,
                    kcal: 0,
                    walkMode: mapWalkingData.walkMode,
                    distance: mapWalkingData.distance,
                    duration: activeDuration,
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
            
            print("🔴 운동 종료 - 총 시간: \(Int(totalDuration))s, 활동 시간: \(Int(activeDuration))s, 비활동: \(Int(inactiveDuration))s")
        }
        
        movementSystem.stopTracking()
        isTracking = false
        
        return mapWalkingData
    }
    
    func reset() {
        // ✅ 타이머 중지
        stopMovementCheckTimer()
        
        isTracking = false
        startTime = nil
        startSteps = 0
        startDistance = 0
        pausedDuration = 0
        pauseStartTime = nil
        
        // ✅ 움직임 추적 리셋
        lastSteps = 0
        lastDistance = 0
        lastMovementTime = nil
        inactiveDuration = 0
        lastInactiveCheckTime = nil
        
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
        
        print("🔄 운동 데이터 리셋")
    }
    
    func getCurrentData() -> MapWalkingModel {
        return mapWalkingData
    }
    
    deinit {
        stopMovementCheckTimer()
    }
}
