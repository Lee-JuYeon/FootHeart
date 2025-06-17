//
//  Untitled.swift
//  FootHeart
//
//  Created by Jupond on 5/19/25.
//
import Foundation
import CoreMotion
import QuartzCore

// MARK: - 걸음 감지 개선 버전 (더 정교한 알고리즘)
class AdvancedStepCounter {
    private let motionManager = CMMotionManager()
    private var stepCount = 0
    private var accelerationData: [(time: TimeInterval, acceleration: Double)] = []
    
    // 걸음 감지 파라미터
    private let dataWindowSize = 20  // 1초간의 데이터 (50Hz 기준으로 50개, 여기서는 20개로 축소)
    private let stepThreshold: Double = 1.1
    private let minimumStepFrequency: Double = 0.5  // 초당 최소 걸음 수
    private let maximumStepFrequency: Double = 3.0  // 초당 최대 걸음 수
    
    var onStepDetected: ((Int) -> Void)?
    var onStepCountUpdated: ((Int) -> Void)?
    
    func startAdvancedStepCounting() {
        guard motionManager.isAccelerometerAvailable else {
            print("가속도계를 사용할 수 없습니다")
            return
        }
        
        stepCount = 0
        accelerationData.removeAll()
        
        motionManager.accelerometerUpdateInterval = 0.02  // 50Hz
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let accelerometerData = data else { return }
            
            let currentTime = CACurrentMediaTime()
            let totalAcceleration = sqrt(
                pow(accelerometerData.acceleration.x, 2) +
                pow(accelerometerData.acceleration.y, 2) +
                pow(accelerometerData.acceleration.z, 2)
            )
            
            // 데이터 추가
            self.accelerationData.append((time: currentTime, acceleration: totalAcceleration))
            
            // 오래된 데이터 제거 (1초 이상 된 데이터)
            self.accelerationData.removeAll { currentTime - $0.time > 1.0 }
            
            // 충분한 데이터가 있으면 분석
            if self.accelerationData.count >= self.dataWindowSize {
                self.analyzeStepPattern()
            }
        }
    }
    
    func stopAdvancedStepCounting() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func analyzeStepPattern() {
        let accelerations = accelerationData.map { $0.acceleration }
        
        // 이동 평균 제거 (고주파 노이즈 제거)
        let average = accelerations.reduce(0, +) / Double(accelerations.count)
        let filteredData = accelerations.map { $0 - average }
        
        // 피크 감지
        var peaks: [Int] = []
        for i in 1..<(filteredData.count - 1) {
            if filteredData[i] > stepThreshold &&
               filteredData[i] > filteredData[i-1] &&
               filteredData[i] > filteredData[i+1] {
                peaks.append(i)
            }
        }
        
        // 걸음 검증 (주파수 기반)
        let validPeaks = filterValidSteps(peaks: peaks, data: filteredData)
        
        if validPeaks.count > stepCount {
            let newSteps = validPeaks.count - stepCount
            stepCount = validPeaks.count
            
            // 각 새로운 걸음에 대해 콜백 호출
            for _ in 0..<newSteps {
                onStepDetected?(stepCount)
            }
            
            onStepCountUpdated?(stepCount)
        }
    }
    
    private func filterValidSteps(peaks: [Int], data: [Double]) -> [Int] {
        var validPeaks: [Int] = []
        
        for peak in peaks {
            // 피크 간격 확인
            if let lastPeak = validPeaks.last {
                let timeDifference = Double(peak - lastPeak) * 0.02  // 샘플링 간격
                let frequency = 1.0 / timeDifference
                
                // 걸음 주파수가 유효 범위 내에 있는지 확인
                if frequency >= minimumStepFrequency && frequency <= maximumStepFrequency {
                    validPeaks.append(peak)
                }
            } else {
                validPeaks.append(peak)
            }
        }
        
        return validPeaks
    }
    
    func reset() {
        stepCount = 0
        accelerationData.removeAll()
        onStepCountUpdated?(0)
    }
    
    func getCurrentStepCount() -> Int {
        return stepCount
    }
}
