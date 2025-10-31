//
//  WalkingVM.swift
//  FootHeart
//
//  Created by Jupond on 5/21/25.
//
import Combine
import CoreLocation

class WalkingVM : ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let walkingRepository : WalkingRepository
    private let themeWalkingRepository: ThemeWalkingProtocol
    
    private let mapWalkingRepository : MapWalkingRepository

    
    init(
        repository : WalkingRepository,
        themeWalkingRepository : ThemeWalkingRepository,
        mapWalkingRepository : MapWalkingRepository
    ){
        self.walkingRepository = repository
        self.themeWalkingRepository = themeWalkingRepository
        self.mapWalkingRepository = mapWalkingRepository
        
        startMonitoring()
    }
    
    
    // 하루측정 걸음 모델
    @Published var dailyWalkingModel: MapWalkingModel = MapWalkingModel(
        date: Date(),
        steps: 0,
        path: [],
        kcal: 0.0,
        walkMode: WalkMode.WALK,
        distance: 0.0,
        duration: 0,
        currentSpeed: 0
    )
    private func startMonitoring() {
        walkingRepository.startDailyWalking()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                
                self?.dailyWalkingModel = model
            }
            .store(in: &cancellables)
    }
    
    func setBMIModel(_ model: BMIModel) {
        mapWalkingRepository.setBMIModel(model)
    }
    
    // ✅ 맵 워킹 (사용자 운동 기록)
    private var mapWalkingSubscription: AnyCancellable?
    @Published var mapWalkingModel: MapWalkingModel = MapWalkingModel(
        date: Date(),
        steps: 0,
        path: [],
        kcal: 0.0,
        walkMode: .WALK,
        distance: 0.0,
        duration: 0,
        currentSpeed: 0
    )
    
    func changeMapWalkMode(_ mode : WalkMode){
        self.mapWalkingModel.walkMode = mode
    }
    
    func startMapWalking() {
        mapWalkingSubscription?.cancel()  // 이전 구독 취소

        mapWalkingSubscription = mapWalkingRepository.start(mode: mapWalkingModel.walkMode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.mapWalkingModel = model
            }
    }
        
    func pauseMapWalking() {
        mapWalkingRepository.pause()
    }
    
    func resumeMapWalking() {
        mapWalkingRepository.resume()
    }
       
    func stopMapWalking() {
        let finalModel = mapWalkingRepository.stop()
        mapWalkingModel = finalModel
        mapWalkingSubscription?.cancel()  // ✅ 구독 취소
        saveMapWalkingData(finalModel)
    }
        
    private func saveMapWalkingData(_ model: MapWalkingModel) {
        print("💾 CoreData 저장: \(model.walkMode.title), \(model.steps)걸음")
    }
    
    func resetMapWalking() {
        mapWalkingRepository.reset()
        mapWalkingModel = mapWalkingRepository.getCurrentData()
    }
    
    func loadWorkoutHistory() -> [MapWalkingModel] {
        return []
    }
    
    deinit {
        walkingRepository.stopDailyWalking()
        mapWalkingSubscription?.cancel()
        cancellables.removeAll()
    }
  
}


/*
 1. 데이터만 전달하는데 DispatchQueue를 main으로 서야하나? backgorund로 써야하나?
 2. receive(on), receive(subscriber)의 차이점은?
 3. Combine, Future에 대해서
 4. 패턴에 대해서 -> xml과 선언형 Ui에 공통적으로 사용할 수 있느 패턴을 개발한다면?
 5. API?
 6. HTTP?
 7.
 */
