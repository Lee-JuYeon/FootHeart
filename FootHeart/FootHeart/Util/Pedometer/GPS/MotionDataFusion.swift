//
//  MotionDataFusion.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//

import Foundation
import CoreMotion // 만보기 기능을 위한 CoreMotion 추가

/*
 CoreMotion의 가속도계, 자이로스코프 데이터를 위치 데이터와 융합:

 */
class MotionDataFusion {
    private let motionManager = CMMotionManager()
    private var heading: Double = 0
    private var acceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    
    private var isMoving: Bool = false

    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion, error == nil else { return }
                
                // 방향 업데이트
                // 방향 업데이트 - heading 속성 직접 사용
                self.heading = motion.heading  // 옵셔널 체크 없이 직접 할당
                
                // 가속도 업데이트
                self.acceleration = motion.userAcceleration
                
                // 기기 움직임 감지
                let accelerationMagnitude = sqrt(
                    pow(self.acceleration.x, 2) +
                    pow(self.acceleration.y, 2) +
                    pow(self.acceleration.z, 2)
                )
                
                self.isMoving = accelerationMagnitude > 0.1 // 약간의 움직임이라도 감지
            }
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func enhanceLocation(_ location: CLLocation) -> CLLocation {
        // 현재 모션 데이터를 사용하여 위치 향상
        // 예: 걷기 방향과 위치의 방향이 크게 다르면 필터링
        
        // 위치 정보의 course(방향)와 모션 데이터의 heading 비교
        if location.course >= 0 && isMoving { // course가 -1인 경우는 방향 정보 없음
            let headingDifference = abs(heading - location.course)
            let adjustedDifference = min(headingDifference, 360 - headingDifference)
            
            // 방향 차이가 너무 크고 이동 중이라면 모션 데이터의 방향 적용
            if adjustedDifference > 45 && location.speed > 0.5 {
                return CLLocation(
                    coordinate: location.coordinate,
                    altitude: location.altitude,
                    horizontalAccuracy: location.horizontalAccuracy,
                    verticalAccuracy: location.verticalAccuracy,
                    course: heading, // 모션 데이터의 방향 사용
                    speed: location.speed,
                    timestamp: location.timestamp
                )
            }
        }
        
        return location
    }
}
