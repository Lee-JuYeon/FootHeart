//
//  WalkingRepository.swift
//  FootHeart
//
//  Created by Jupond on 5/21/25.
//

import Combine
import CoreMotion
import CoreLocation

class WalkingRepository : WalkingProtocol {
    
    private let movementSystem = HybridStepTracker()
    private let stepSubject = PassthroughSubject<MapWalkingModel, Never>()
    private let walkingSubject = PassthroughSubject<MapWalkingModel, Never>()

    private enum UserDefaultsKey {
        static let todayStepData = "todayStepData"
        static let todayDate = "todayDate"
    }
     
    
    init() {
        setupMovementSystem()
        loadTodayStepData()  // 🆕 StepData 로드
        checkMidnight()
    }
    
   
//    private var currentStepData : StepData = StepData(
//        steps: 0,
//        distance: 0.0,
//        currentSpeed: 0.0,
//        averageSpeed: 0.0,
//        elapsedTime: 0,
//        source: ""
//    )
    
    private var currentWalkingData: MapWalkingModel = MapWalkingModel(
        date: Date(),
        steps: 0,
        path: [],
        kcal: 0.0,
        walkMode: WalkMode.WALK,
        distance: 0.0,
        duration: 0,
        currentSpeed: 0
    )
    
    private func setupMovementSystem() {
        // 걸음이 확정되었을때
        movementSystem.onWalkingUpdate = { [weak self] walkingModel in
            guard let self = self else { return }
            
            // ✅ 칼로리 계산 추가 (옵션)
            // let calculator = StepCalorieCalculator()
            // let kcal = calculator.calculateCaloriesWithRealSpeed(...)
            
            self.currentWalkingData = walkingModel
            self.saveWalkingData(walkingModel)
            self.walkingSubject.send(walkingModel)
            
        }
    }
    
    // 걸음수 측정 시작
    func startDailyWalking() -> AnyPublisher<MapWalkingModel, Never> {
        checkAndResetIfNewDay() // 걸음수 초기화 메소드
        movementSystem.startTracking() // 걸음수 측정 시작
        
        // 초기값 전송
//        let initialModel = StepData(
//            walkingCount: currentStepCount,
//            walkingPath: []
//        )
//        stepSubject.send(initialModel)
        walkingSubject.send(currentWalkingData)
        return walkingSubject.eraseToAnyPublisher()
    }
    
    // 걸음수 측정 중단.
    func stopDailyWalking() {
        movementSystem.stopTracking()
        
        // 중단 시점의 데이터 저장
        saveWalkingData(currentWalkingData)
    }
    
    // 현재 걸음 데이터 조회
    func getCurrentWalkingData() -> MapWalkingModel {
        return currentWalkingData
    }
    
    private func checkAndResetIfNewDay() {
        let calendar = Calendar.current
        
        if let savedDate = UserDefaults.standard.object(forKey: "todayDate") as? Date {
            if !calendar.isDate(savedDate, inSameDayAs: Date()) {
                resetDailySteps()
            }
        }
    }
    
    private func resetDailySteps() {
//        currentStepCount = 0
        
//        let model = StepData(
//            walkingCount: 0,
//            walkingPath: []
//        )
//        stepSubject.send(model)
        currentWalkingData = MapWalkingModel(
            date: Date(),
            steps: 0,
            path: [],
            kcal: 0.0,
            walkMode: WalkMode.WALK,
            distance: 0.0,
            duration: 0,
            currentSpeed: 0
        )
        
      
        // HybridStepTracker 리셋
        movementSystem.reset()
        
        // UserDefaults에 초기화된 데이터 저장
        saveWalkingData(currentWalkingData)
               
        
        // Subscriber에게 초기화 알림
        walkingSubject.send(currentWalkingData)
    }
    
    // 🆕 오늘의 StepData 저장
    private func saveWalkingData(_ model: MapWalkingModel) {
        UserDefaults.standard.setCodable(model, forKey: UserDefaultsKey.todayStepData)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.todayDate)
    }
    
    // 🆕 오늘의 StepData 불러오기
    private func loadTodayStepData() {
        // 저장된 날짜 확인
        if let savedDate = UserDefaults.standard.object(forKey: UserDefaultsKey.todayDate) as? Date {
            let calendar = Calendar.current
            
            // 같은 날짜인지 확인
            if calendar.isDate(savedDate, inSameDayAs: Date()) {
                // 저장된 StepData 불러오기
                if let savedWalkingModel = UserDefaults.standard.codable(
                    MapWalkingModel.self,
                    forKey: UserDefaultsKey.todayStepData
                ) {
                    currentWalkingData = savedWalkingModel
                } else {
                    // 저장된 데이터가 없으면 초기화
                    resetDailySteps()
                }
            } else {
                // 날짜가 다르면 초기화
                resetDailySteps()
            }
        } else {
            // 첫 실행
            resetDailySteps()
        }
    }
    
    // 걸음수 초기화 메소드
    private func checkMidnight() {
        // 자정에 초기화하는 타이머
        let calendar = Calendar.current
        let now = Date()
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        let timeInterval = midnight.timeIntervalSince(now)
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.resetDailySteps()
            self?.checkMidnight() // 다음 자정 타이머 재설정
        }
    }
    
    deinit {
        stopDailyWalking()
    }
 
}
