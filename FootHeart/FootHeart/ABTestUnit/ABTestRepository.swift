//
//  ABTestRepository.swift
//  FootHeart
//
//  Created by Jupond on 10/16/25.
//

import Combine
import CoreMotion
import CoreLocation

class ABTestRepository : ABTestProtocol {
    
    /*
     MovementFeedbackSystem() : 걸음 추적 알고리즘. 정확도 50% 이하
     RealtimeStepCounter() :
     AdvancedStepCounter() :
     */
    private let movementSystem = MovementFeedbackSystem() // 걸음 추적 알고리즘.
    private let hybridTracker = HybridStepTracker() // 개선된 걸음 추적 알고리즘.

    
    private let stepSubject = PassthroughSubject<StepABTestModel, Never>()
    private var currentStepCount: Int = 0
    private var testStartDate: Date = Date()  // ✅ 시작 시간 기록

    init() {
//        setupMovementSystem()
        setupHybridTracker()

    }
    private func setupHybridTracker() {
//        // 걸음 수 업데이트 콜백
//        hybridTracker.onStepUpdate = { [weak self] stepData in
//            guard let self = self else { return }
//            
//            self.currentStepCount = stepData.steps
//            
//            let model = StepABTestModel(
//                manualStepCount: 0,
//                autoStepCount: stepData.steps,
//                autoStepPath: [],
//                date: Date()
//            )
//            self.stepSubject.send(model)
//        }
//        
//        // 데이터 소스 변경 알림
//        hybridTracker.onSourceChange = { source in
//            print("🔄 ABTest - 데이터 소스 변경: \(source)")
//        }
    }
    
    private func setupMovementSystem() {
        // 걸음이 확정되었을때
        movementSystem.onStepConfirmed = { [weak self] stepCount in
            guard let self = self else { return }
            self.currentStepCount = stepCount // 현재 걸음수
            
            let model = StepABTestModel(
                manualStepCount: 0,
                autoStepCount: stepCount,
                autoStepPath: [],
                date: Date() // walkingPath는 사용하지 않음
            )
            self.stepSubject.send(model)
        }
    }
    
    // 걸음수 측정 시작
    func startWalking() -> AnyPublisher<StepABTestModel, Never> {
        // movementSystem.startMonitoring() // 걸음수 측정 시작
        
        testStartDate = Date()
        currentStepCount = 0
        
        hybridTracker.startTracking()

        // 초기값 전송
        let initialModel = StepABTestModel(
            manualStepCount: 0,
            autoStepCount: currentStepCount,
            autoStepPath: [],
            date: testStartDate
        )
        stepSubject.send(initialModel)
        
        print("✅ ABTest 시작 - \(testStartDate)")

        return stepSubject.eraseToAnyPublisher()
    }
    
    // 걸음수 측정 중단.
    func stopWalking() {
//        movementSystem.stopMonitoring()
        hybridTracker.stopTracking()
        
        // 최종 결과 저장 (필요시)
        let finalSteps = currentStepCount
        let duration = Date().timeIntervalSince(testStartDate)
        
                
        // reset
        currentStepCount = 0
        hybridTracker.reset()
//        movementSystem.reset()
        
        let model = StepABTestModel(
            manualStepCount: 0,
            autoStepCount: 0,
            autoStepPath: [],
            date: Date()
        )
        stepSubject.send(model)
    }
    
    // 현재 사용 중인 데이터 소스 확인
    func getCurrentDataSource() -> String {
        return hybridTracker.getCurrentSource()
    }
    
    // 보폭 설정 (선택)
    func setAverageStride(_ stride: Double) {
        hybridTracker.setAverageStride(stride)
    }
}
