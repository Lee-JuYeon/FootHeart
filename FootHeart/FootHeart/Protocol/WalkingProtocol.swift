//
//  WalkingProtocol.swift
//  FootHeart
//
//  Created by Jupond on 5/21/25.
//
import Foundation
import Combine

protocol WalkingProtocol {
    
    /*
     - 하루 총 걸음수 start
     - 하루 총 걸음수 stop
     - 하루 총 걸음수 get step count
     
     - 사용자 측정 걸음수 start
     - 사용자 측정 걸음수 stop
     - 사용자 측정 걸음수 get stop count
     */
    
    func startDailyWalking() -> AnyPublisher<MapWalkingModel, Never>
    func stopDailyWalking()
       
    
   
    

}
