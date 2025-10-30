//
//  ABTestVM.swift
//  FootHeart
//
//  Created by Jupond on 10/16/25.
//

import Combine
import CoreLocation

class ABTestVM : ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    private let abTestRepository : ABTestRepository = ABTestRepository()
    
    init(){
        
    }
    
    
    // 현재 걸음 모델
    @Published var abTestWalkingModel : StepABTestModel = StepABTestModel(
        manualStepCount: 0,
        autoStepCount: 0,
        autoStepPath: [],
        date: Date()
    )
    
    func startMonitoringStepABTest(){
        abTestRepository.startWalking()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.abTestWalkingModel = model
            }
            .store(in: &cancellables)
    }
    
    func stopMonitoringStepABTest() {
        abTestRepository.stopWalking()
    }
    
    
    
    deinit {
        cancellables.removeAll()
    }
  
}

