//
//  ABTestProtocol.swift
//  FootHeart
//
//  Created by Jupond on 10/16/25.
//
import Combine

protocol ABTestProtocol {
    
    func startWalking() -> AnyPublisher<StepABTestModel, Never>
    func stopWalking()
       

}
