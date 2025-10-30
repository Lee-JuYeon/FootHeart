//
//  StepData.swift
//  FootHeart
//
//  Created by Jupond on 10/23/25.
//
import Foundation

// 🆕 걸음 데이터 구조체
struct StepData : Codable {
    let steps: Int
    let distance: Double           // 총 이동 거리 (m)
    let currentSpeed: Double       // 현재 속도 (m/s)
    let averageSpeed: Double       // 평균 속도 (m/s)
    let elapsedTime: TimeInterval  // 경과 시간 (초) // duration
    let source: String             // 데이터 소스
    
    // 편의 속성
    var speedKmh: Double {
        return currentSpeed * 3.6  // m/s를 km/h로 변환
    }
    
    var averageSpeedKmh: Double {
        return averageSpeed * 3.6
    }
    
    var distanceKm: Double {
        return distance / 1000.0
    }
}
