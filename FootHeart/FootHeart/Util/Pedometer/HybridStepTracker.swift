//
//  HybridStepTracker.swift
//  FootHeart
//
//  Created by Jupond on 10/19/25.
//

import Foundation
import CoreLocation
import CoreMotion
import Combine
import QuartzCore

// Pedometer + 가속도계 + GPS 하이브리드 걸음 측정 시스템
class HybridStepTracker: NSObject {
    
    // MARK: - Properties
    
    // 센서 매니저들
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private let locationManager = CLLocationManager()
    
    // 걸음 수 데이터
    private var totalSteps: Int = 0              // 최종 걸음 수
    private var pedometerSteps: Int = 0          // CMPedometer 원본값
    private var gpsEstimatedSteps: Int = 0       // GPS 기반 추정값
    private var accelerometerSteps: Int = 0      // 가속도계 기반값
    
    // GPS 위치 데이터
    private var lastLocation: CLLocation?        // 마지막 유효 위치
    private var totalDistance: CLLocationDistance = 0  // 총 이동 거리 (m)
    private let averageStride: Double = 0.7      // 평균 보폭 (m)
    private var previousSpeed: Double = 0        // 이전 속도 (m/s)
    private let kalmanFilter = OptimizedKalmanFilter(processNoise: 0.01, measurementNoise: 10.0)
    
    // 속도 추적
    private var currentSpeed: Double = 0         // 현재 속도 (m/s)
    private var averageSpeed: Double = 0         // 평균 속도 (m/s)
    private var speedHistory: [Double] = []      // 속도 히스토리
    private let speedHistorySize = 10            // 히스토리 크기
    
    // 시간 추적
    private var startTime: Date?                 // 측정 시작 시간
    private var elapsedTime: TimeInterval = 0   // 경과 시간 (초)
    
    // 가속도계 데이터
    private var accelerationBuffer: [Double] = []  // 가속도 버퍼
    private var lastStepTime: TimeInterval = 0     // 마지막 걸음 시간
    
    // 데이터 소스 오프셋 (소스 전환 시 걸음 수 보정용)
    private var pedometerOffset: Int = 0
    private var accelerometerOffset: Int = 0
    private var gpsOffset: Int = 0
    private var stepsAtSourceSwitch: Int = 0     // 소스 전환 시점의 걸음 수
    
    // 데이터 소스 우선순위
    private enum DataSource {
        case pedometer      // 1순위: CMPedometer
        case accelerometer  // 2순위: 가속도계
        case gps           // 3순위: GPS
    }
    private var currentSource: DataSource = .pedometer
    
    // 데이터 소스 유효성 체크
    private var isPedometerWorking: Bool = false
    private var isAccelerometerWorking: Bool = false
    private var lastPedometerUpdate: Date = Date()
    private let pedometerTimeout: TimeInterval = 5.0
    
    // 경로 추적
    private var walkingPath: [CLLocation] = []   // 이동 경로
    private var walkMode: WalkMode = WalkMode.WALK  // 운동 모드
    
    // GPS 일시중지 상태 관리
    private var isGPSPaused = false              // GPS 일시중지 여부
    private var poorSignalCount = 0              // 나쁜 신호 연속 카운트
    private var goodSignalCount = 0              // 좋은 신호 연속 카운트
    private let signalCheckThreshold = 5         // 신호 체크 임계값 (5번 연속)
    private var lastGoodLocation: CLLocation?    // 마지막 좋은 위치
    
    // 콜백
    var onWalkingUpdate: ((MapWalkingModel) -> Void)?
    var onSourceChange: ((String) -> Void)?
    
    // Combine Publisher
    private let walkingSubject = PassthroughSubject<MapWalkingModel, Never>()
    var walkingPublisher: AnyPublisher<MapWalkingModel, Never> {
        return walkingSubject.eraseToAnyPublisher()
    }
    
    private let stepSubject = PassthroughSubject<StepData, Never>()
    var stepPublisher: AnyPublisher<StepData, Never> {
        return stepSubject.eraseToAnyPublisher()
    }
    
    // 소스 모니터링 타이머
    private var checkTimer: Timer?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    
    // 측정 시작
    func startTracking() {
        reset()
        startTime = Date()
        
        startPedometerTracking()
        startAccelerometerTracking()
        startGPSTracking()
        startSourceMonitoring()
        
        print("HybridStepTracker, startTracking // 하이브리드 걸음 측정 시작")
    }
    
    // 측정 중지
    func stopTracking() {
        pedometer.stopUpdates()
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        checkTimer?.invalidate()
        
        print("HybridStepTracker, stopTracking // 걸음 측정 중지")
    }
    
    // 모든 데이터 리셋
    func reset() {
        // 걸음 수 리셋
        totalSteps = 0
        pedometerSteps = 0
        gpsEstimatedSteps = 0
        accelerometerSteps = 0
        
        // GPS 데이터 리셋
        totalDistance = 0
        lastLocation = nil
        previousSpeed = 0
        kalmanFilter.reset()
        
        // 버퍼 리셋
        accelerationBuffer.removeAll()
        lastStepTime = 0
        
        // 오프셋 리셋
        pedometerOffset = 0
        accelerometerOffset = 0
        gpsOffset = 0
        stepsAtSourceSwitch = 0
        
        // 속도 데이터 리셋
        currentSpeed = 0
        averageSpeed = 0
        speedHistory.removeAll()
        
        // 시간 데이터 리셋
        startTime = nil
        elapsedTime = 0
        
        // 경로 리셋
        walkingPath.removeAll()
        
        // GPS 일시중지 상태 리셋
        isGPSPaused = false
        poorSignalCount = 0
        goodSignalCount = 0
        lastGoodLocation = nil
        
        // 초기 모델 전송
        let resetModel = MapWalkingModel(
            date: Date(),
            steps: 0,
            path: [],
            kcal: 0.0,
            walkMode: walkMode,
            distance: 0,
            duration: 0,
            currentSpeed: 0
        )
        onWalkingUpdate?(resetModel)
        
        print("HybridStepTracker, reset // GPS 상태 완전 리셋")
    }
    
    // 현재 걸음 데이터 조회
    func getCurrentStepData() -> StepData {
        return StepData(
            steps: totalSteps,
            distance: totalDistance,
            currentSpeed: currentSpeed,
            averageSpeed: averageSpeed,
            elapsedTime: elapsedTime,
            source: getSourceName(currentSource)
        )
    }
    
    // MARK: - GPS Setup
    
    // Location Manager 설정
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation  // 최고 정확도
        locationManager.distanceFilter = 2.0                  // 2m마다 업데이트
        locationManager.allowsBackgroundLocationUpdates = true  // 백그라운드 허용
        locationManager.pausesLocationUpdatesAutomatically = false  // 자동 일시중지 비활성화
        locationManager.activityType = .fitness               // 피트니스 활동
    }
    
    // GPS 추적 시작
    private func startGPSTracking() {
        // iOS 버전별 권한 체크
        let authStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authStatus = locationManager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            print("HybridStepTracker, startGPSTracking // GPS 시작")
        case .denied, .restricted:
            print("HybridStepTracker, startGPSTracking // 위치 권한 없음")
        @unknown default:
            break
        }
    }
    
    // GPS 신호가 좋은지 판단 (정확도 40m 이하)
    private func isGoodSignal(_ location: CLLocation) -> Bool {
        let accuracy = location.horizontalAccuracy
        return accuracy > 0 && accuracy <= 40
    }
    
    // GPS 신호가 나쁜지 판단 (정확도 60m 이상)
    private func isPoorSignal(_ location: CLLocation) -> Bool {
        let accuracy = location.horizontalAccuracy
        return accuracy < 0 || accuracy > 60
    }
    
    // GPS 위치 데이터 처리
    private func processGPSLocation(_ location: CLLocation) {
        // 신호 품질 체크
        let goodSignal = isGoodSignal(location)
        let poorSignal = isPoorSignal(location)
        
        // GPS 일시중지 상태 처리
        if isGPSPaused {
            // 좋은 신호 확인
            if goodSignal {
                goodSignalCount += 1
                poorSignalCount = 0
                print("HybridStepTracker, processGPSLocation // 좋은 신호 감지 (\(goodSignalCount)/\(signalCheckThreshold))")
                
                // 5번 연속 좋은 신호면 GPS 재개
                if goodSignalCount >= signalCheckThreshold {
                    isGPSPaused = false
                    goodSignalCount = 0
                    
                    // Kalman Filter 리셋 (새로운 시작)
                    kalmanFilter.reset()
                    
                    print("HybridStepTracker, processGPSLocation // GPS 측정 재개 - 신호 회복")
                    
                    // 첫 위치로 재시작
                    lastLocation = location
                    lastGoodLocation = location
                    walkingPath.append(location)
                    speedHistory.removeAll()
                    previousSpeed = 0
                    
                    return
                }
            } else {
                goodSignalCount = 0
            }
            
            // 여전히 일시중지 상태
            print("HybridStepTracker, processGPSLocation // GPS 일시중지 중 - accuracy: \(Int(location.horizontalAccuracy))m")
            return
        }
        
        // GPS 활성 상태에서 나쁜 신호 확인
        if poorSignal {
            poorSignalCount += 1
            goodSignalCount = 0
            print("HybridStepTracker, processGPSLocation // 나쁜 신호 감지 (\(poorSignalCount)/\(signalCheckThreshold))")
            
            // 5번 연속 나쁜 신호면 GPS 일시중지
            if poorSignalCount >= signalCheckThreshold {
                isGPSPaused = true
                poorSignalCount = 0
                
                print("HybridStepTracker, processGPSLocation // GPS 측정 일시중지 - 신호 불량 (실내 진입)")
                
                return
            }
        } else {
            poorSignalCount = 0
        }
        
        // 정상 GPS 처리 시작
        let accuracy = location.horizontalAccuracy
        
        // 정확도 기본 체크 (40m 초과 시 무시)
        if accuracy > 40 {
            print("HybridStepTracker, processGPSLocation // GPS 정확도 낮음 (\(Int(accuracy))m) - 데이터 무시")
            return
        }
        
        // Kalman Filter 적용 (노이즈 제거)
        let filteredLocation = kalmanFilter.filter(location: location)
        
        // 첫 위치 처리
        guard let lastLoc = lastLocation else {
            lastLocation = filteredLocation
            lastGoodLocation = filteredLocation
            walkingPath.append(filteredLocation)
            return
        }
        
        // 시간 간격 확인 (0.5초 이상)
        let timeInterval = filteredLocation.timestamp.timeIntervalSince(lastLoc.timestamp)
        guard timeInterval > 0.5 else { return }
        
        // 거리 계산
        let distance = filteredLocation.distance(from: lastLoc)
        
        // 위치 점프 감지 (3초 안에 30m 이상 이동 시 무시)
        if timeInterval < 3.0 && distance > 30 {
            print("HybridStepTracker, processGPSLocation // 위치 점프 감지 (\(Int(distance))m in \(String(format: "%.1f", timeInterval))s)")
            lastLocation = filteredLocation
            return
        }
        
        // 속도 계산 (m/s)
        let calculatedSpeed = distance / timeInterval
        
        // 정지 상태 감지 (0.3m/s 미만, 2m 미만 이동)
        if calculatedSpeed < 0.3 && distance < 2.0 {
            lastLocation = filteredLocation
            return
        }
        
        // 속도 유효성 검사 (보행 속도: 0.3 ~ 3.0 m/s)
        guard calculatedSpeed >= 0.3 && calculatedSpeed <= 3.0 else {
            print("HybridStepTracker, processGPSLocation // 비정상 속도 (\(String(format: "%.2f", calculatedSpeed))m/s)")
            lastLocation = filteredLocation
            return
        }
        
        // 속도 일관성 체크 (150% 이상 변화 시 무시)
        if previousSpeed > 0 {
            let speedChange = abs(calculatedSpeed - previousSpeed) / previousSpeed
            if speedChange > 1.5 {
                print("HybridStepTracker, processGPSLocation // 급격한 속도 변화 (\(Int(speedChange * 100))%)")
                lastLocation = filteredLocation
                return
            }
        }
        
        // 가속도 체크 (2.0 m/s² 초과 시 무시)
        if previousSpeed > 0 {
            let acceleration = abs(calculatedSpeed - previousSpeed) / timeInterval
            if acceleration > 2.0 {
                print("HybridStepTracker, processGPSLocation // 비정상 가속도 (\(String(format: "%.2f", acceleration))m/s2)")
                lastLocation = filteredLocation
                return
            }
        }
        
        // 유효한 위치 - 경로에 추가
        walkingPath.append(filteredLocation)
        totalDistance += distance
        
        // 속도 히스토리 업데이트
        speedHistory.append(calculatedSpeed)
        if speedHistory.count > speedHistorySize {
            speedHistory.removeFirst()
        }
        
        // 현재 속도 및 평균 속도 계산
        currentSpeed = calculatedSpeed
        if !speedHistory.isEmpty {
            averageSpeed = speedHistory.reduce(0, +) / Double(speedHistory.count)
        }
        
        // 경과 시간 계산
        if let start = startTime {
            elapsedTime = Date().timeIntervalSince(start)
        }
        
        // GPS 기반 걸음 수 추정 (거리 / 평균 보폭)
        gpsEstimatedSteps = Int(totalDistance / averageStride)
        
        // 상태 업데이트
        previousSpeed = calculatedSpeed
        lastLocation = filteredLocation
        lastGoodLocation = filteredLocation
        
        // 총 걸음 수 업데이트
        updateTotalSteps()
        
        print("HybridStepTracker, processGPSLocation // GPS 활성: dist=\(String(format: "%.1f", distance))m, spd=\(String(format: "%.2f", calculatedSpeed))m/s, acc=\(Int(accuracy))m")
    }
    
    // MARK: - Pedometer (1순위)
    
    // CMPedometer 추적 시작
    private func startPedometerTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("HybridStepTracker, startPedometerTracking // CMPedometer 사용 불가")
            return
        }
        
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else {
                print("HybridStepTracker, startPedometerTracking // CMPedometer 오류")
                return
            }
            
            // Pedometer 걸음 수 업데이트
            self.pedometerSteps = data.numberOfSteps.intValue
            self.isPedometerWorking = true
            self.lastPedometerUpdate = Date()
            
            // 현재 소스가 Pedometer이고 작동 중이면 총 걸음 수 업데이트
            if self.currentSource == .pedometer {
                self.updateTotalSteps()
            }
        }
        
        print("HybridStepTracker, startPedometerTracking // CMPedometer 시작")
    }
    
    // MARK: - Accelerometer (2순위)
    
    // 가속도계 추적 시작
    private func startAccelerometerTracking() {
        guard motionManager.isAccelerometerAvailable else {
            print("HybridStepTracker, startAccelerometerTracking // 가속도계 사용 불가")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1  // 0.1초마다 업데이트
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else {
                return
            }
            
            self.processAccelerometerData(data)
        }
        
        print("HybridStepTracker, startAccelerometerTracking // 가속도계 시작")
    }
    
    // 가속도계 데이터 처리
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        // 총 가속도 계산
        let totalAcceleration = sqrt(
            pow(data.acceleration.x, 2) +
            pow(data.acceleration.y, 2) +
            pow(data.acceleration.z, 2)
        )
        
        // 버퍼에 추가
        accelerationBuffer.append(totalAcceleration)
        if accelerationBuffer.count > 10 {
            accelerationBuffer.removeFirst()
        }
        
        // 걸음 감지 (임계값 1.2, 0.3초 간격)
        let threshold = 1.2
        let currentTime = CACurrentMediaTime()
        
        if totalAcceleration > threshold && (currentTime - lastStepTime) > 0.3 {
            accelerometerSteps += 1
            lastStepTime = currentTime
            isAccelerometerWorking = true
            
            // 현재 소스가 가속도계면 총 걸음 수 업데이트
            if currentSource == .accelerometer {
                updateTotalSteps()
            }
        }
    }
    
    // MARK: - Source Monitoring
    
    // 데이터 소스 모니터링 시작
    private func startSourceMonitoring() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkDataSources()
        }
    }
    
    // 데이터 소스 상태 체크 및 전환
    private func checkDataSources() {
        // Pedometer 타임아웃 체크 (5초)
        let pedometerTimeout = Date().timeIntervalSince(lastPedometerUpdate) > self.pedometerTimeout
        
        if pedometerTimeout {
            isPedometerWorking = false
        }
        
        // 우선순위에 따른 소스 전환
        // 1순위: Pedometer
        if isPedometerWorking && currentSource != .pedometer {
            switchToSource(.pedometer)
        }
        // 2순위: Accelerometer
        else if !isPedometerWorking && isAccelerometerWorking && currentSource != .accelerometer {
            switchToSource(.accelerometer)
        }
        // 3순위: GPS
        else if !isPedometerWorking && !isAccelerometerWorking && currentSource != .gps {
            switchToSource(.gps)
        }
        
        // 총 걸음 수 업데이트
        updateTotalSteps()
    }
    
    // 데이터 소스 전환
    private func switchToSource(_ newSource: DataSource) {
        // 같은 소스면 무시
        guard newSource != currentSource else { return }
        
        let oldSource = currentSource
        
        // 전환 시점의 걸음 수 저장
        stepsAtSourceSwitch = totalSteps
        
        // 새로운 소스의 오프셋 계산
        switch newSource {
        case .pedometer:
            pedometerOffset = stepsAtSourceSwitch - pedometerSteps
            print("HybridStepTracker, switchToSource // Pedometer로 전환 (offset: \(pedometerOffset))")
            
        case .accelerometer:
            accelerometerOffset = stepsAtSourceSwitch - accelerometerSteps
            print("HybridStepTracker, switchToSource // 가속도계로 전환 (offset: \(accelerometerOffset))")
            
        case .gps:
            gpsOffset = stepsAtSourceSwitch - gpsEstimatedSteps
            print("HybridStepTracker, switchToSource // GPS로 전환 (offset: \(gpsOffset))")
        }
        
        currentSource = newSource
        onSourceChange?(getSourceName(newSource))
        
        print("HybridStepTracker, switchToSource // 데이터 소스 전환: \(getSourceName(oldSource)) -> \(getSourceName(newSource))")
    }
    
    // 총 걸음 수 업데이트
    private func updateTotalSteps() {
        // 현재 소스에 따라 걸음 수 계산
        switch currentSource {
        case .pedometer:
            totalSteps = pedometerSteps + pedometerOffset
        case .accelerometer:
            totalSteps = accelerometerSteps + accelerometerOffset
        case .gps:
            totalSteps = gpsEstimatedSteps + gpsOffset
        }
        
        // 경과 시간 계산
        if let start = startTime {
            elapsedTime = Date().timeIntervalSince(start)
        }
        
        // MapWalkingModel 생성 및 전송
        let walkingModel = MapWalkingModel(
            date: Date(),
            steps: totalSteps,
            path: walkingPath.map { MapWalkingModel.LocationData(from: $0) },
            kcal: 0.0,
            walkMode: walkMode,
            distance: totalDistance,
            duration: elapsedTime,
            currentSpeed: currentSpeed
        )
        
        onWalkingUpdate?(walkingModel)
        walkingSubject.send(walkingModel)
    }
    
    // MARK: - Helper Methods
    
    // 데이터 소스 이름 반환
    private func getSourceName(_ source: DataSource) -> String {
        switch source {
        case .pedometer:
            return "CMPedometer"
        case .accelerometer:
            return "가속도계"
        case .gps:
            return "GPS"
        }
    }
    
    // 현재 데이터 소스 조회
    func getCurrentSource() -> String {
        return getSourceName(currentSource)
    }
}

// MARK: - CLLocationManagerDelegate

extension HybridStepTracker: CLLocationManagerDelegate {
    
    // 위치 권한 변경 시
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // iOS 버전별 권한 체크
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("HybridStepTracker, locationManagerDidChangeAuthorization // 위치 권한 거부됨")
        default:
            break
        }
    }
    
    // 위치 업데이트 시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        processGPSLocation(location)
    }
    
    // 위치 업데이트 실패 시
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("HybridStepTracker, locationManager:didFailWithError // 위치 업데이트 실패: \(error.localizedDescription)")
    }
}
