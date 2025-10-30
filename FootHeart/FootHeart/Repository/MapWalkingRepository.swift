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
    
    // ✅ currentState 제거
    private var mapWalkingData: MapWalkingModel
    
    // 시작 시점 기록
    private var startTime: Date?
    private var startSteps: Int = 0
    private var startDistance: Double = 0
    
    // 일시정지 관련
    private var pausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    
    private var isTracking: Bool = false

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
                  let startTime = self.startTime else {
                return
            }
            
            // ✅ 운동 중이 아니면 무시
            guard self.isTracking,
                  let startTime = self.startTime else {
                print("⚠️ 운동 중이 아님 - 업데이트 무시")
                return
            }
                      
            
            let currentDuration = Date().timeIntervalSince(startTime) - self.pausedDuration
            
            let mapModel = MapWalkingModel(
                date: startTime,
                steps: walkingModel.steps - self.startSteps,
                path: walkingModel.path,
                kcal: 0.0,
                walkMode: self.mapWalkingData.walkMode,
                distance: walkingModel.distance - self.startDistance,
                duration: currentDuration,
                currentSpeed: walkingModel.currentSpeed
            )
            
            self.mapWalkingData = mapModel
            self.mapSubject.send(mapModel)
        }
    }
    
    // MARK: - Public Methods (상태 체크 없이 단순 실행)
    
    /// ✅ 운동 시작 - 그냥 시작
    func start(mode: WalkMode) -> AnyPublisher<MapWalkingModel, Never> {
        movementSystem.startTracking()
        
        // ✅ 추적 시작
        isTracking = true
        
        startTime = Date()
        let currentData = movementSystem.getCurrentStepData()
        startSteps = currentData.steps
        startDistance = currentData.distance
        
        pausedDuration = 0
        pauseStartTime = nil
        
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
        
        print("🟢 운동 시작 - 모드: \(mode.title)")
        mapSubject.send(mapWalkingData)
        return mapSubject.eraseToAnyPublisher()
    }
    
    /// ✅ 일시정지 - 그냥 일시정지
    func pause() {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return
        }
        
        pauseStartTime = Date()
        print("⏸️ 운동 일시정지")
    }
    
    /// ✅ 재개 - 그냥 재개
    func resume() {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return
        }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        pauseStartTime = nil
        print("▶️ 운동 재개")
    }
    
    /// ✅ 종료 - 그냥 종료하고 데이터 반환
    func stop() -> MapWalkingModel {
        guard isTracking else {
            print("⚠️ 운동 중이 아님")
            return mapWalkingData
        }
        
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
        }
        
        if let startTime = startTime {
            let totalDuration = Date().timeIntervalSince(startTime) - pausedDuration
            
            let finalModel = MapWalkingModel(
                date: startTime,
                steps: mapWalkingData.steps,
                path: mapWalkingData.path,
                kcal: 0.0,
                walkMode: mapWalkingData.walkMode,
                distance: mapWalkingData.distance,
                duration: totalDuration,
                currentSpeed: 0
            )
            
            mapWalkingData = finalModel
        }
        
        movementSystem.stopTracking()
        
        print("🔴 운동 종료 - \(mapWalkingData.steps)걸음")
        
        return mapWalkingData
    }
    
    /// ✅ 리셋 - 그냥 리셋
    func reset() {
        isTracking = false
        startTime = nil
        startSteps = 0
        startDistance = 0
        pausedDuration = 0
        pauseStartTime = nil
        
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
}
