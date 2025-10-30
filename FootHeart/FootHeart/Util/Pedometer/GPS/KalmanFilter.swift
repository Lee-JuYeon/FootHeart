//
//  KalmanFilter.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//

import Foundation
import CoreLocation

class OptimizedKalmanFilter {
    // 상태 벡터 성분들
    private var estimatedLat: Double = 0
    private var estimatedLong: Double = 0
    private var estimatedLatVelocity: Double = 0
    private var estimatedLongVelocity: Double = 0
    private var estimatedAccuracy: Double = 0  // 정확도 정보 추적
    
    // 오차 공분산 요소들
    private var errorCovarianceLat: Double = 1.0
    private var errorCovarianceLong: Double = 1.0
    private var errorCovarianceLatVel: Double = 1.0
    private var errorCovarianceLongVel: Double = 1.0
    
    // 상태 간 상관관계 (KalmanFilter의 행렬 접근의 장점 일부 도입)
    private var covarianceLatLong: Double = 0.0
    private var covarianceLatLatVel: Double = 0.0
    private var covarianceLongLongVel: Double = 0.0
    
    // 노이즈 파라미터
    private var processNoise: Double
    private var measurementNoise: Double
    private var adaptiveFactor: Double = 1.0 // 적응형 필터링을 위한 계수
    
    // 상태 추적
    private var lastTimestamp: Date?
    private var isInitialized: Bool = false
    private var locationHistory: [CLLocation] = []
    private let maxHistorySize: Int = 5
    
    // 환경 설정
    private var isLowAccuracyEnvironment: Bool = false
    
    init(processNoise: Double = 0.01, measurementNoise: Double = 10.0) {
        self.processNoise = processNoise
        self.measurementNoise = measurementNoise
    }
    
    // 환경에 따른 파라미터 조정 메서드들
    func setProcessNoise(_ value: Double) {
        processNoise = value
    }
    
    func setMeasurementNoise(_ value: Double) {
        measurementNoise = value
    }
    
    func setEnvironment(isLowAccuracy: Bool) {
        isLowAccuracyEnvironment = isLowAccuracy
        
        // 오프라인 모드 또는 저정확도 환경에서 파라미터 자동 조정
        if isLowAccuracy {
            processNoise = 0.005  // 더 낮은 프로세스 노이즈
            measurementNoise = 15.0  // 더 높은 측정 노이즈 (낮은 신뢰도)
        } else {
            processNoise = 0.01  // 표준 프로세스 노이즈
            measurementNoise = 10.0  // 표준 측정 노이즈
        }
    }
    
    func reset() {
        isInitialized = false
        locationHistory.removeAll()
        
        // 모든 상태 및 공분산 초기화
        estimatedLat = 0
        estimatedLong = 0
        estimatedLatVelocity = 0
        estimatedLongVelocity = 0
        estimatedAccuracy = 0
        
        errorCovarianceLat = 1.0
        errorCovarianceLong = 1.0
        errorCovarianceLatVel = 1.0
        errorCovarianceLongVel = 1.0
        
        covarianceLatLong = 0.0
        covarianceLatLatVel = 0.0
        covarianceLongLongVel = 0.0
        
        lastTimestamp = nil
        adaptiveFactor = 1.0
    }
    
    func filter(location: CLLocation) -> CLLocation {
        // 위치 이력 추가
        addToHistory(location)
        
        // 첫 번째 측정값 처리
        if !isInitialized {
            return initializeFilter(location)
        }
        
        // 측정 노이즈 동적 조정 (위치 정확도에 따라)
        adjustNoiseBasedOnAccuracy(location.horizontalAccuracy)
        
        // 시간 간격 계산
        guard let deltaTime = calculateTimeInterval(location) else {
            return location
        }
        
        // 예측 단계
        predictState(deltaTime)
        
        // 업데이트 단계
        updateState(location)
        
        // 결과 생성
        return createFilteredLocation(location)
    }
    
    // MARK: - 내부 구현 메서드
    
    private func initializeFilter(_ location: CLLocation) -> CLLocation {
        estimatedLat = location.coordinate.latitude
        estimatedLong = location.coordinate.longitude
        estimatedAccuracy = location.horizontalAccuracy
        lastTimestamp = location.timestamp
        isInitialized = true
        return location
    }
    
    private func addToHistory(_ location: CLLocation) {
        locationHistory.append(location)
        if locationHistory.count > maxHistorySize {
            locationHistory.removeFirst()
        }
    }
    
    private func adjustNoiseBasedOnAccuracy(_ accuracy: CLLocationAccuracy) {
        // 정확도에 따른 측정 노이즈 동적 조정
        if accuracy <= 5 {
            // 매우 정확한 측정 - 낮은 측정 노이즈
            measurementNoise = 3.0 * adaptiveFactor
        } else if accuracy <= 10 {
            // 중간 정확도 - 중간 측정 노이즈
            measurementNoise = 10.0 * adaptiveFactor
        } else if accuracy <= 20 {
            // 낮은 정확도 - 높은 측정 노이즈
            measurementNoise = 20.0 * adaptiveFactor
        } else {
            // 매우 낮은 정확도 - 매우 높은 측정 노이즈
            measurementNoise = 30.0 * adaptiveFactor
        }
    }
    
    private func calculateTimeInterval(_ location: CLLocation) -> TimeInterval? {
        guard let lastTime = lastTimestamp else { return nil }
        
        let deltaTime = location.timestamp.timeIntervalSince(lastTime)
        lastTimestamp = location.timestamp
        
        // 너무 작은 시간 간격이나 너무 큰 시간 간격은 문제가 될 수 있음
        if deltaTime < 0.01 || deltaTime > 10.0 {
            return nil
        }
        
        return deltaTime
    }
    
    private func predictState(_ deltaTime: TimeInterval) {
        // 이전 상태와 속도를 기반으로 현재 상태 예측
        estimatedLat += estimatedLatVelocity * deltaTime
        estimatedLong += estimatedLongVelocity * deltaTime
        
        // 오차 공분산 예측 업데이트 (프로세스 노이즈 포함)
        errorCovarianceLat += 2 * covarianceLatLatVel * deltaTime +
                               errorCovarianceLatVel * deltaTime * deltaTime +
                               processNoise * deltaTime
        
        errorCovarianceLong += 2 * covarianceLongLongVel * deltaTime +
                                errorCovarianceLongVel * deltaTime * deltaTime +
                                processNoise * deltaTime
        
        // 속도 공분산 업데이트
        errorCovarianceLatVel += processNoise * deltaTime
        errorCovarianceLongVel += processNoise * deltaTime
        
        // 상관관계 업데이트
        covarianceLatLatVel += processNoise * deltaTime
        covarianceLongLongVel += processNoise * deltaTime
        covarianceLatLong += processNoise * deltaTime
    }
    
    private func updateState(_ location: CLLocation) {
        // 측정값
        let measuredLat = location.coordinate.latitude
        let measuredLong = location.coordinate.longitude
        
        // 잔차 계산 (측정값 - 예측값)
        let residualLat = measuredLat - estimatedLat
        let residualLong = measuredLong - estimatedLong
        
        // 잔차 공분산 계산
        let residualCovarianceLat = errorCovarianceLat + measurementNoise
        let residualCovarianceLong = errorCovarianceLong + measurementNoise
        
        // 칼만 이득 계산
        let kalmanGainLat = errorCovarianceLat / residualCovarianceLat
        let kalmanGainLong = errorCovarianceLong / residualCovarianceLong
        let kalmanGainLatVel = covarianceLatLatVel / residualCovarianceLat
        let kalmanGainLongVel = covarianceLongLongVel / residualCovarianceLong
        
        // 상태 업데이트
        estimatedLat += kalmanGainLat * residualLat
        estimatedLong += kalmanGainLong * residualLong
        
        // 속도 업데이트 (측정값과 예측값의 차이를 바탕으로)
        if let deltaTime = calculateTimeInterval(location) {
            if deltaTime > 0 {
                // 속도 업데이트 (이동이 있을 때만)
                if location.speed > 0.1 {
                    estimatedLatVelocity += kalmanGainLatVel * residualLat
                    estimatedLongVelocity += kalmanGainLongVel * residualLong
                }
            }
        }
        
        // 오차 공분산 업데이트
        errorCovarianceLat *= (1 - kalmanGainLat)
        errorCovarianceLong *= (1 - kalmanGainLong)
        errorCovarianceLatVel -= kalmanGainLatVel * covarianceLatLatVel
        errorCovarianceLongVel -= kalmanGainLongVel * covarianceLongLongVel
        
        // 상관관계 업데이트
        covarianceLatLatVel *= (1 - kalmanGainLat)
        covarianceLongLongVel *= (1 - kalmanGainLong)
        covarianceLatLong -= kalmanGainLat * covarianceLatLong
        
        // 적응형 인자 업데이트 (새로운 측정값과 예측값의 일치 정도를 기반으로)
        updateAdaptiveFactor(residualLat, residualLong, residualCovarianceLat, residualCovarianceLong)
    }
    
    private func updateAdaptiveFactor(_ residualLat: Double, _ residualLong: Double,
                                     _ residualCovarianceLat: Double, _ residualCovarianceLong: Double) {
        // 잔차의 정규화된 크기 계산
        let normalizedResidualLat = residualLat * residualLat / residualCovarianceLat
        let normalizedResidualLong = residualLong * residualLong / residualCovarianceLong
        let normalizedResidual = (normalizedResidualLat + normalizedResidualLong) / 2.0
        
        // 잔차가 예상보다 크면 적응 인자 증가 (측정 노이즈 증가)
        if normalizedResidual > 3.0 {
            adaptiveFactor = min(3.0, adaptiveFactor * 1.1)
        }
        // 잔차가 예상보다 작으면 적응 인자 감소 (측정 노이즈 감소)
        else if normalizedResidual < 0.5 {
            adaptiveFactor = max(0.5, adaptiveFactor * 0.9)
        }
    }
    
    private func createFilteredLocation(_ originalLocation: CLLocation) -> CLLocation {
        // 필터링된 위치 생성
        let filteredCoordinate = CLLocationCoordinate2D(
            latitude: estimatedLat,
            longitude: estimatedLong
        )
        
        // 내부적으로 계산된 정확도 추정
        let estimatedHorizontalAccuracy = min(
            sqrt(errorCovarianceLat + errorCovarianceLong),
            originalLocation.horizontalAccuracy
        )
        
        // 속도 이상값 검출 및 보정
        var filteredSpeed = originalLocation.speed
        let calculatedSpeed = sqrt(
            estimatedLatVelocity * estimatedLatVelocity +
            estimatedLongVelocity * estimatedLongVelocity
        ) * 111000 // 대략적인 m/s 변환 (1도 ≈ 111km)
        
        // 계산된 속도와 측정된 속도 간 큰 차이가 있으면 계산된 속도 사용
        if abs(calculatedSpeed - originalLocation.speed) > originalLocation.speed * 0.5 {
            filteredSpeed = calculatedSpeed
        }
        
        return CLLocation(
            coordinate: filteredCoordinate,
            altitude: originalLocation.altitude,
            horizontalAccuracy: estimatedHorizontalAccuracy,
            verticalAccuracy: originalLocation.verticalAccuracy,
            course: originalLocation.course,
            speed: filteredSpeed,
            timestamp: originalLocation.timestamp
        )
    }
    
    // 이상치 감지 메서드 (선택적으로 사용)
    func isOutlier(_ location: CLLocation) -> Bool {
        // 역사적 데이터가 충분하지 않으면 이상치 검사 건너뛰기
        if locationHistory.count < 3 {
            return false
        }
        
        // 이전 위치
        let previousLocation = locationHistory[locationHistory.count - 2]
        
        // 시간 간격
        let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
        if timeInterval < 0.01 {
            return true // 너무 짧은 시간 간격
        }
        
        // 거리 계산
        let distance = location.distance(from: previousLocation)
        
        // 속도 계산 (m/s)
        let speed = distance / timeInterval
        
        // 비정상적으로 높은 속도 (20 m/s ≈ 72 km/h)
        if speed > 20.0 {
            return true
        }
        
        // 이전 속도와 비교하여 가속도 계산
        if locationHistory.count >= 3 {
            let secondPreviousLocation = locationHistory[locationHistory.count - 3]
            let previousTimeInterval = previousLocation.timestamp.timeIntervalSince(secondPreviousLocation.timestamp)
            
            if previousTimeInterval >= 0.01 {
                let previousDistance = previousLocation.distance(from: secondPreviousLocation)
                let previousSpeed = previousDistance / previousTimeInterval
                
                // 가속도 계산 (m/s²)
                let acceleration = abs(speed - previousSpeed) / timeInterval
                
                // 비정상적인 가속도 (5 m/s² ≈ 0.5G)
                if acceleration > 5.0 {
                    return true
                }
            }
        }
        
        return false
    }
}
