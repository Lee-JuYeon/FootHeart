//
//  MovementFeedbackSystem.swift
//  FootHeart
//
//  Created by Jupond on 5/19/25.
//

import CoreMotion
import UIKit

/*
 - 문제점
 OptimizedKalmanFilter, RealtimeStepCounter등은 모두 가속도계 기반임.
 따라서 손을 고정하고 걷는 상황에서는 정확도가 굉장히 떨어짐.
 
 - 해결방안
 GPS 기반 걸음 수 추정을 보완하여 측정한다.

 */
// 실시간 움직임 감지 및 피드백 시스템
class MovementFeedbackSystem {
    private let motionManager = CMMotionManager()
    private var movementHistory: [Double] = []
    private let historySize = 10
    
    // 콜백들
    var onMovementDetected: ((Double) -> Void)?  // 움직임 강도 (0-1)
    var onStepPredicted: (() -> Void)?           // 걸음 예측됨
    var onStepConfirmed: ((Int) -> Void)?        // 걸음 확정됨
    
    // 실시간 걸음 측정기와 연동
    private let stepCounter = RealtimeStepCounter()
    
    // 설정값
    private let movementThreshold: Double = 0.3
    private let stepPredictionThreshold: Double = 1.0
    
    func startMonitoring() {
        // 움직임 감지 시작
        startMovementDetection()
        
        // 걸음 측정 시작
        stepCounter.onStepDetected = { [weak self] stepCount in
            self?.onStepConfirmed?(stepCount)
        }
        stepCounter.startStepCounting()
    }
    
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        stepCounter.stopStepCounting()
    }
    
    private func startMovementDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.05  // 20Hz - 매우 빠른 업데이트
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            // 총 가속도 계산
            let totalAcceleration = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            // 움직임 히스토리 업데이트
            self.updateMovementHistory(totalAcceleration)
            
            // 즉시 움직임 피드백
            let movementIntensity = self.calculateMovementIntensity(totalAcceleration)
            self.onMovementDetected?(movementIntensity)
            
            // 걸음 예측
            if self.predictStep(totalAcceleration) {
                self.onStepPredicted?()
            }
        }
    }
    
    private func updateMovementHistory(_ acceleration: Double) {
        movementHistory.append(acceleration)
        if movementHistory.count > historySize {
            movementHistory.removeFirst()
        }
    }
    
    private func calculateMovementIntensity(_ currentAcceleration: Double) -> Double {
        guard !movementHistory.isEmpty else { return 0 }
        
        let average = movementHistory.reduce(0, +) / Double(movementHistory.count)
        let movement = abs(currentAcceleration - average)
        
        // 0-1 사이로 정규화
        return min(movement / 2.0, 1.0)
    }
    
    private func predictStep(_ currentAcceleration: Double) -> Bool {
        guard movementHistory.count >= 5 else { return false }
        
        let recentAverage = Array(movementHistory.suffix(5)).reduce(0, +) / 5.0
        let acceleration = currentAcceleration - recentAverage
        
        return acceleration > stepPredictionThreshold
    }
    
    func reset() {
        movementHistory.removeAll()
        stepCounter.reset()
    }
    
    // 설정 조정 메서드들
    func adjustSensitivity(threshold: Double, stepInterval: TimeInterval) {
        stepCounter.setThreshold(threshold)
        stepCounter.setMinimumStepInterval(stepInterval)
    }
}
