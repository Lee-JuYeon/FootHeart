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

/*
 TODO List :
 
 앨리베이터 내에서 걸음이 초기화 되었다가, 엘리베이터 밖으로 나오면 다시 갯수가 원래대로 복귀됨.
 */

// MARK: - 가속도계 + GPS 하이브리드 걸음 측정 시스템
class HybridStepTracker: NSObject {
    
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private let locationManager = CLLocationManager()
    
    // 걸음 데이터
    private var totalSteps: Int = 0
    private var pedometerSteps: Int = 0
    private var gpsEstimatedSteps: Int = 0
    
    // GPS 관련
    private var lastLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0
    private let averageStride: Double = 0.7
    private var previousSpeed: Double = 0
    private let kalmanFilter = OptimizedKalmanFilter(processNoise: 0.01, measurementNoise: 10.0)
    
    // 🆕 속도 추적
    private var currentSpeed: Double = 0  // m/s
    private var averageSpeed: Double = 0  // m/s (이동 평균)
    private var speedHistory: [Double] = []
    private let speedHistorySize = 10
    
    // 🆕 경과 시간 추적
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0
    
    // 가속도계 관련
    private var accelerationBuffer: [Double] = []
    private var lastStepTime: TimeInterval = 0
    private var accelerometerSteps: Int = 0
    
    private var pedometerOffset: Int = 0
    private var accelerometerOffset: Int = 0
    private var gpsOffset: Int = 0
    
    private var stepsAtSourceSwitch: Int = 0
    
    // 우선순위 상태
    private enum DataSource {
        case pedometer
        case accelerometer
        case gps
    }
    private var currentSource: DataSource = .pedometer
    
    // 데이터 소스 유효성
    private var isPedometerWorking: Bool = false
    private var isAccelerometerWorking: Bool = false
    private var lastPedometerUpdate: Date = Date()
    private let pedometerTimeout: TimeInterval = 5.0
    
    // 경로 추적용 추가
    private var walkingPath: [CLLocation] = []
    private var walkMode: WalkMode = WalkMode.WALK  // 기본값
    
    // 🆕 콜백 개선 - 속도와 거리 정보 포함
//    var onStepUpdate: ((StepData) -> Void)?
    var onWalkingUpdate: ((MapWalkingModel) -> Void)?
    var onSourceChange: ((String) -> Void)?
    
    private let walkingSubject = PassthroughSubject<MapWalkingModel, Never>()  // ✅ Subject 변경
    var walkingPublisher: AnyPublisher<MapWalkingModel, Never> {
        return walkingSubject.eraseToAnyPublisher()
    }
    
    // Combine
    private let stepSubject = PassthroughSubject<StepData, Never>()
    var stepPublisher: AnyPublisher<StepData, Never> {
        return stepSubject.eraseToAnyPublisher()
    }
    
    private var checkTimer: Timer?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    
    func startTracking() {
        reset()
        startTime = Date()  // 🆕 시작 시간 기록
        
        startPedometerTracking()
        startAccelerometerTracking()
        startGPSTracking()
        startSourceMonitoring()
        
        print("✅ 하이브리드 걸음 측정 시작")
    }
    
    func stopTracking() {
        pedometer.stopUpdates()
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
        checkTimer?.invalidate()
        
        print("🛑 걸음 측정 중지")
    }
    
    func reset() {
        totalSteps = 0
        pedometerSteps = 0
        gpsEstimatedSteps = 0
        accelerometerSteps = 0
        totalDistance = 0
        lastLocation = nil
        accelerationBuffer.removeAll()
        lastStepTime = 0
        previousSpeed = 0
        kalmanFilter.reset()
        
        // ✅ 오프셋 초기화
        pedometerOffset = 0
        accelerometerOffset = 0
        gpsOffset = 0
        stepsAtSourceSwitch = 0
        
        // 🆕 속도 관련 리셋
        currentSpeed = 0
        averageSpeed = 0
        speedHistory.removeAll()
        startTime = nil
        elapsedTime = 0
        
        walkingPath.removeAll()  // ✅ 경로 초기화

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
    }
    
    // 🆕 현재 상태 조회
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
    
    // MARK: - 1순위: CMPedometer
    
    private func startPedometerTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            print("⚠️ CMPedometer 사용 불가")
            isPedometerWorking = false
            return
        }
        
        let startDate = Date()
        
        pedometer.startUpdates(from: startDate) { [weak self] pedometerData, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ CMPedometer 오류: \(error.localizedDescription)")
                self.isPedometerWorking = false
                return
            }
            
            guard let data = pedometerData else { return }
            
            DispatchQueue.main.async {
                self.pedometerSteps = data.numberOfSteps.intValue
                self.isPedometerWorking = true
                self.lastPedometerUpdate = Date()
                
                if self.currentSource != .pedometer {
//                    self.currentSource = .pedometer
//                    self.onSourceChange?("CMPedometer")
//                    print("📱 데이터 소스 전환: CMPedometer")
                    self.switchToSource(.pedometer)
                }
                
                self.updateTotalSteps()
            }
        }
        
        print("📱 CMPedometer 시작")
    }
    
    // MARK: - 2순위: 가속도계
    private func startAccelerometerTracking() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ 가속도계 사용 불가")
            isAccelerometerWorking = false
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.05
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else {
                self?.isAccelerometerWorking = false
                return
            }
            
            self.isAccelerometerWorking = true
            self.processAccelerometerData(data)
        }
        
        print("📳 가속도계 시작")
    }
    
    private func processAccelerometerData(_ data: CMAccelerometerData) {
        let totalAcceleration = sqrt(
            pow(data.acceleration.x, 2) +
            pow(data.acceleration.y, 2) +
            pow(data.acceleration.z, 2)
        )
        
        accelerationBuffer.append(totalAcceleration)
        if accelerationBuffer.count > 20 {
            accelerationBuffer.removeFirst()
        }
        
        if accelerationBuffer.count >= 20 {
            detectStepFromAccelerometer(currentAcceleration: totalAcceleration)
        }
    }
    
    private func detectStepFromAccelerometer(currentAcceleration: Double) {
        let currentTime = CACurrentMediaTime()
        
        guard currentTime - lastStepTime >= 0.25 else { return }
        
        let average = accelerationBuffer.reduce(0, +) / Double(accelerationBuffer.count)
        let threshold = average + 0.15
        
        if currentAcceleration > threshold && currentAcceleration > 1.1 {
            accelerometerSteps += 1
            lastStepTime = currentTime
            
            if !isPedometerWorking && currentSource != .accelerometer {
//                currentSource = .accelerometer
//                onSourceChange?("가속도계")
//                print("📳 데이터 소스 전환: 가속도계")
                switchToSource(.accelerometer)
            }
            
            updateTotalSteps()
        }
    }
    
    // MARK: - 3순위: GPS
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    private func startGPSTracking() {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            print("📍 GPS 시작")
        case .denied, .restricted:
            print("❌ 위치 권한 없음")
        @unknown default:
            break
        }
    }
    
    private func processGPSLocation(_ location: CLLocation) {
        // 1. Kalman Filter 적용
        let filteredLocation = kalmanFilter.filter(location: location)
        
        guard let lastLoc = lastLocation else {
            lastLocation = filteredLocation
            return
        }
        
        // ✅ 경로에 추가
        walkingPath.append(filteredLocation)
        
        // 2. 시간 간격 확인
        let timeInterval = filteredLocation.timestamp.timeIntervalSince(lastLoc.timestamp)
        guard timeInterval > 1.0 else { return }
        
        // 3. 거리 계산
        let distance = filteredLocation.distance(from: lastLoc)
        
        // 4. 속도 계산
        let calculatedSpeed = distance / timeInterval  // m/s
        
        // 5. GPS 정확도 체크
        let accuracy = filteredLocation.horizontalAccuracy
        
        if accuracy > 15 {
            print("⚠️ GPS 정확도 낮음 (\(Int(accuracy))m) - 데이터 무시")
            lastLocation = filteredLocation
            return
        }
        
        // 6. 속도 유효성 검사 (보행 속도: 0.5 ~ 2.5 m/s)
        guard calculatedSpeed >= 0.5 && calculatedSpeed <= 2.5 else {
            print("⚠️ 비정상 속도 (\(String(format: "%.2f", calculatedSpeed))m/s) - 데이터 무시")
            lastLocation = filteredLocation
            return
        }
        
        // 7. 속도 일관성 체크
        if previousSpeed > 0 {
            let speedChange = abs(calculatedSpeed - previousSpeed) / previousSpeed
            if speedChange > 1.0 {
                print("⚠️ 급격한 속도 변화 (\(Int(speedChange * 100))%) - 데이터 무시")
                lastLocation = filteredLocation
                return
            }
        }
        
        // 8. 가속도 체크
        if previousSpeed > 0 {
            let acceleration = abs(calculatedSpeed - previousSpeed) / timeInterval
            if acceleration > 2.0 {
                print("⚠️ 비정상 가속도 (\(String(format: "%.2f", acceleration))m/s²) - 데이터 무시")
                lastLocation = filteredLocation
                return
            }
        }
        
        // 🆕 9. 모든 검증 통과 - 속도 및 거리 업데이트
        totalDistance += distance
        
        // 현재 속도 업데이트
        currentSpeed = calculatedSpeed
        
        // 속도 히스토리에 추가 (이동 평균 계산용)
        speedHistory.append(calculatedSpeed)
        if speedHistory.count > speedHistorySize {
            speedHistory.removeFirst()
        }
        
        // 평균 속도 계산
        if !speedHistory.isEmpty {
            averageSpeed = speedHistory.reduce(0, +) / Double(speedHistory.count)
        }
        
        previousSpeed = calculatedSpeed
        
        // 10. 걸음 수 계산
        gpsEstimatedSteps = Int(totalDistance / averageStride)
        
        lastLocation = filteredLocation
        
        // 11. CMPedometer와 가속도계가 모두 작동 안 하면 GPS 사용
        if !isPedometerWorking && !isAccelerometerWorking {
            if currentSource != .gps {
//                currentSource = .gps
//                onSourceChange?("GPS")
//                print("📍 데이터 소스 전환: GPS")
                switchToSource(.gps)
            }
            updateTotalSteps()
        }
        
        print("📍 GPS: 거리 +\(String(format: "%.1f", distance))m, 속도 \(String(format: "%.2f", calculatedSpeed))m/s (\(String(format: "%.1f", calculatedSpeed * 3.6))km/h)")
    }
    
    // MARK: - 데이터 소스 모니터링
    
    private func startSourceMonitoring() {
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkDataSources()
        }
    }
    
    private func checkDataSources() {
        // 경과 시간 업데이트
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        // CMPedometer 타임아웃 체크
        if Date().timeIntervalSince(lastPedometerUpdate) > pedometerTimeout {
            if isPedometerWorking {
                isPedometerWorking = false
                print("⚠️ CMPedometer 타임아웃 - 작동 중지됨")
            }
        }
        
        // GPS 정확도 확인
        var isGPSReliable = true
        if let lastLoc = lastLocation {
            if lastLoc.horizontalAccuracy > 15 {
                isGPSReliable = false
                print("⚠️ GPS 신뢰도 낮음 - Urban Canyon 환경")
            }
        }
        
        // 우선순위에 따라 데이터 소스 선택
        let newSource: DataSource
        if isPedometerWorking {
            newSource = .pedometer
        } else if isAccelerometerWorking {
            newSource = .accelerometer
        } else if isGPSReliable {
            newSource = .gps
        } else {
            newSource = isAccelerometerWorking ? .accelerometer : .gps
        }
        
        if newSource != currentSource {
            currentSource = newSource
            let sourceName = getSourceName(newSource)
            onSourceChange?(sourceName)
            print("📡 데이터 소스 자동 전환: \(sourceName)")
            updateTotalSteps()
        }
    }
    
    // MARK: - 걸음 수 업데이트
    
    private func updateTotalSteps() {
        let previousSteps = totalSteps
        
        // ✅ 개선: 현재 소스의 원본값 + 오프셋 = 연속된 걸음 수
        switch currentSource {
        case .pedometer:
            totalSteps = pedometerSteps + pedometerOffset
            
        case .accelerometer:
            totalSteps = accelerometerSteps + accelerometerOffset
            
        case .gps:
            totalSteps = gpsEstimatedSteps + gpsOffset
        }
        
        // 변경이 있을 때만 콜백 호출
        if totalSteps != previousSteps || currentSpeed > 0 {
//            let stepData = StepData(
//                steps: totalSteps,
//                distance: totalDistance,
//                currentSpeed: currentSpeed,
//                averageSpeed: averageSpeed,
//                elapsedTime: elapsedTime,
//                source: getSourceName(currentSource)
//            )
//            
//            onStepUpdate?(stepData)
//            stepSubject.send(stepData)
            
            // ✅ MapWalkingModel 생성
            let walkingModel = MapWalkingModel(
                date: Date(),
                steps: totalSteps,
                path: walkingPath.map { MapWalkingModel.LocationData(from: $0) },  // ✅ 변환
                kcal: 0.0,  // Calculator에서 계산 예정
                walkMode: walkMode,
                distance: totalDistance,
                duration: elapsedTime,
                currentSpeed: currentSpeed
            )
            
            onWalkingUpdate?(walkingModel)  // ✅ 콜백 호출
            walkingSubject.send(walkingModel)  // ✅ Subject 전송
            print("🚶🚶🚶  HybridStepTracker: steps=\(totalSteps), distance=\(totalDistance)m, elapsed=\(elapsedTime)s")

        }
    }
    
    // ✅ 새로운 메서드: 데이터 소스 전환 처리
    private func switchToSource(_ newSource: DataSource) {
        // 이전 소스가 같으면 처리 안 함
        guard newSource != currentSource else { return }
        
        let oldSource = currentSource
        
        // 전환 시점의 totalSteps 저장
        stepsAtSourceSwitch = totalSteps
        
        // 새로운 소스의 오프셋 계산
        switch newSource {
        case .pedometer:
            // 현재 totalSteps - Pedometer 원본값 = 오프셋
            pedometerOffset = stepsAtSourceSwitch - pedometerSteps
            print("📱 Pedometer로 전환 (offset: \(pedometerOffset), 현재 Pedometer: \(pedometerSteps))")
            
        case .accelerometer:
            // 현재 totalSteps - 가속도계 원본값 = 오프셋
            accelerometerOffset = stepsAtSourceSwitch - accelerometerSteps
            print("📳 가속도계로 전환 (offset: \(accelerometerOffset), 현재 가속도계: \(accelerometerSteps))")
            
        case .gps:
            // 현재 totalSteps - GPS 원본값 = 오프셋
            gpsOffset = stepsAtSourceSwitch - gpsEstimatedSteps
            print("📍 GPS로 전환 (offset: \(gpsOffset), 현재 GPS: \(gpsEstimatedSteps))")
        }
        
        currentSource = newSource
        onSourceChange?(getSourceName(newSource))
        
        print("🔄 데이터 소스 전환: \(getSourceName(oldSource)) → \(getSourceName(newSource))")
    }
        
    
    // MARK: - Helper Methods
    
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
    
    func getCurrentSource() -> String {
        return getSourceName(currentSource)
    }
    
    func setAverageStride(_ stride: Double) {
        // 보폭 설정
    }
}

// MARK: - CLLocationManagerDelegate
extension HybridStepTracker: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ 위치 권한 거부됨")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        processGPSLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 업데이트 실패: \(error.localizedDescription)")
    }
}
