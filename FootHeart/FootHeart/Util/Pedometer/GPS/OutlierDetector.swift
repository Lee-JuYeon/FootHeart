//
//  OutlierDetector.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//

import Foundation
import CoreLocation

/*
 이상치 탐지기
 */
class OutlierDetector {
    private var recentLocations: [CLLocation] = []
    private let maxLocations = 10
    private let speedThreshold: Double = 20.0 // m/s (약 72km/h)
    private let accelerationThreshold: Double = 5.0 // m/s²
    private let distanceThreshold: Double = 100.0 // 직전 위치에서 너무 멀리 떨어진 위치 감지
    
    func isOutlier(_ location: CLLocation) -> Bool {
        // 충분한 이전 위치가 없으면 이상치 검사 건너뛰기
        guard recentLocations.count >= 2 else {
            addLocation(location)
            return false
        }
        
        let previousLocation = recentLocations.last!
        let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
        
        // 시간 간격이 너무 작으면 건너뛰기 (0.1초 미만)
        if timeInterval < 0.1 {
            return true
        }
        
        // 거리 계산 (m)
        let distance = location.distance(from: previousLocation)
        
        // 직전 위치에서 너무 멀리 떨어진 경우
        if distance > distanceThreshold {
            return true
        }
        
        // 속도 계산 (m/s)
        let speed = distance / timeInterval
        
        // 비정상적으로 높은 속도는 이상치로 간주
        if speed > speedThreshold {
            return true
        }
        
        // 이전 속도와 비교하여 가속도 계산
        if recentLocations.count >= 3 {
            let secondPreviousLocation = recentLocations[recentLocations.count - 2]
            let previousTimeInterval = previousLocation.timestamp.timeIntervalSince(secondPreviousLocation.timestamp)
            
            // 이전 시간 간격이 너무 작으면 가속도 계산 건너뛰기
            if previousTimeInterval >= 0.1 {
                let previousDistance = previousLocation.distance(from: secondPreviousLocation)
                let previousSpeed = previousDistance / previousTimeInterval
                
                // 가속도 계산
                let acceleration = abs(speed - previousSpeed) / timeInterval
                
                // 비정상적인 가속도는 이상치로 간주
                if acceleration > accelerationThreshold {
                    return true
                }
            }
        }
        
        // 이상치가 아닌 경우 위치 추가
        addLocation(location)
        return false
    }
    
    private func addLocation(_ location: CLLocation) {
        recentLocations.append(location)
        
        // 최대 개수 유지
        if recentLocations.count > maxLocations {
            recentLocations.removeFirst()
        }
    }
    
    func reset() {
        recentLocations.removeAll()
    }
}
