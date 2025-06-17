//
//  RealtiemStep.swift
//  FootHeart
//
//  Created by Jupond on 5/19/25.
//

import Foundation
import CoreMotion
import QuartzCore

class RealtimeStepCounter {
    private let motionManager = CMMotionManager()
    private var stepCount = 0
    private var lastStepTime: TimeInterval = 0
    private var threshold: Double = 1.2  // 걸음 감지 임계값
    private var lastAcceleration: Double = 0
    private var isStepDetected = false
    private var minimumStepInterval: TimeInterval = 0.3  // 최소 걸음 간격 (초)
    
    // 걸음 감지를 위한 설정값들
    private let sampleRate: TimeInterval = 0.02  // 50Hz (1초에 50번 측정)
    private var accelerationHistory: [Double] = []
    private let historySize = 5  // 최근 5개 데이터 포인트 유지
    
    // 콜백 클로저
    var onStepDetected: ((Int) -> Void)?
    
    func startStepCounting() {
        guard motionManager.isAccelerometerAvailable else {
            print("가속도계를 사용할 수 없습니다")
            return
        }
        
        // 초기화
        stepCount = 0
        lastStepTime = 0
        accelerationHistory.removeAll()
        
        // 가속도계 설정
        motionManager.accelerometerUpdateInterval = sampleRate
        
        // 가속도계 시작
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let accelerometerData = data else {
                if let error = error {
                    print("가속도계 오류: \(error.localizedDescription)")
                }
                return
            }
            
            self.processAccelerometerData(accelerometerData)
        }
        
        print("실시간 걸음 측정 시작")
    }
    
    func stopStepCounting() {
        motionManager.stopAccelerometerUpdates()
        print("실시간 걸음 측정 중지")
    }
    
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        // 총 가속도 계산 (중력 포함)
        let totalAcceleration = sqrt(
            pow(data.acceleration.x, 2) +
            pow(data.acceleration.y, 2) +
            pow(data.acceleration.z, 2)
        )
        
        // 가속도 히스토리에 추가
        accelerationHistory.append(totalAcceleration)
        
        // 히스토리 크기 유지
        if accelerationHistory.count > historySize {
            accelerationHistory.removeFirst()
        }
        
        // 충분한 데이터가 모이면 걸음 감지 시작
        if accelerationHistory.count >= historySize {
            detectStep(currentAcceleration: totalAcceleration)
        }
        
        lastAcceleration = totalAcceleration
    }
    
    private func detectStep(currentAcceleration: Double) {
        let currentTime = CACurrentMediaTime()
        
        // 최소 걸음 간격 체크
        if currentTime - lastStepTime < minimumStepInterval {
            return
        }
        
        // 평균 가속도 계산
        let averageAcceleration = accelerationHistory.reduce(0, +) / Double(accelerationHistory.count)
        
        // 피크 감지 알고리즘
        // 1. 현재 가속도가 임계값을 넘어야 함
        // 2. 현재 가속도가 평균보다 상당히 높아야 함
        // 3. 이전에 걸음이 감지되지 않은 상태여야 함
        
        let accelerationDifference = currentAcceleration - averageAcceleration
        
        if !isStepDetected &&
           currentAcceleration > threshold &&
           accelerationDifference > 0.3 {
            
            // 걸음 감지됨
            isStepDetected = true
            stepCount += 1
            lastStepTime = currentTime
            
            // 콜백 호출
            onStepDetected?(stepCount)
            
            print("걸음 감지: \(stepCount), 가속도: \(currentAcceleration)")
            
        } else if isStepDetected && currentAcceleration < threshold - 0.2 {
            // 가속도가 충분히 떨어지면 다음 걸음을 감지할 준비
            isStepDetected = false
        }
    }
    
    func reset() {
        stepCount = 0
        lastStepTime = 0
        accelerationHistory.removeAll()
        isStepDetected = false
        onStepDetected?(0)
    }
    
    func getCurrentStepCount() -> Int {
        return stepCount
    }
    
    // 걸음 감지 민감도 조정
    func setThreshold(_ newThreshold: Double) {
        threshold = newThreshold
    }
    
    // 최소 걸음 간격 조정
    func setMinimumStepInterval(_ interval: TimeInterval) {
        minimumStepInterval = interval
    }
}
