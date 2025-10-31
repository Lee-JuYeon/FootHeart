//
//  MapWalkingModel.swift
//  FootHeart
//
//  Created by Jupond on 10/25/25.
//
import Foundation
import CoreLocation

struct MapWalkingModel : Codable {
    let date : Date             // 날짜 -
    let steps : Int             // 걸은 걸음 수v
    let path : [LocationData]     // 이동 경로
    let kcal : Double           // 소모 칼로리v
    var walkMode : WalkMode    // 걷기모드 v
    let distance : Double       // 거리 (meter 미터)-
    let duration : TimeInterval // 시간-
    let currentSpeed : Double // 현재 속도
    
    // ✅ CLLocation 대신 사용할 Codable 구조체
    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let altitude: Double
        let timestamp: Date
        let horizontalAccuracy: Double
        let verticalAccuracy: Double
        
        init(from location: CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude
            self.timestamp = location.timestamp
            self.horizontalAccuracy = location.horizontalAccuracy
            self.verticalAccuracy = location.verticalAccuracy
        }
        
        // CLLocation으로 복원
        func toCLLocation() -> CLLocation {
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                timestamp: timestamp
            )
        }
    }
        
       
    /// 날짜 포맷 (예: 2025년 1월 20일 14:30)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
    }
    
    /// 요일 포맷 (예: 월요일)
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    /// 시간 포맷 (예: 1시간 23분)
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60  // ✅ 초 추가
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)  // ✅ "분:초"
        } else {
            return String(format: "%d초", seconds)  // ✅ "초"만 표시
        }
    }
    
    /// 거리 포맷 (km)
    var distanceInKm: Double {
        return distance / 1000.0
    }
    
    /// 평균 속도 계산 (km/h) - 달리기, 자전거용
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        let distanceKm = distance / 1000.0
        let durationHours = duration / 3600.0
        return distanceKm / durationHours
    }
    
    /// 평균 페이스 계산 (분/km) - 달리기용
    var averagePace: String {
        guard distance > 0 else { return "0'00\"" }
        let distanceKm = distance / 1000.0
        let paceMinutes = duration / 60.0 / distanceKm
        let minutes = Int(paceMinutes)
        let seconds = Int((paceMinutes - Double(minutes)) * 60)
        return "\(minutes)'\(String(format: "%02d", seconds))\""
    }
}
