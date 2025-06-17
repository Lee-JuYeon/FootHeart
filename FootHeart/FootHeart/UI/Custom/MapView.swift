//
//  MapView.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreMotion // 만보기 기능을 위한 CoreMotion 추가
import Network


protocol MapViewDelegate: AnyObject {
    func presentAlert(title: String, message: String, actions: [UIAlertAction])
    func showTrackingSummary(distance: Double, steps: Int) // 추적 요약 표시를 위한 메서드 추가
}

class MapView: UIView {
    // MARK: - 속성
    private let locationManager = CLLocationManager()
    private let pedometer = CMPedometer()
    private var pathCoordinates: [CLLocationCoordinate2D] = []
    private var locationSamples: [CLLocation] = []
    private var polyline: MKPolyline?
    private var isTracking = false
    private var stepCount: Int = 0
    
    // GPS 정확도 향상을 위한 추가 속성
    private var kalmanFilter: OptimizedKalmanFilter
    private let outlierDetector = OutlierDetector()
    private let motionFusion = MotionDataFusion()
    private let networkMonitor = NetworkMonitor()
    private var isOnline = true
    private var connectionType: NetworkMonitor.ConnectionType = .unknown
    private var trackingStartTime: Date?
    private var totalDistance: CLLocationDistance = 0
    
    weak var delegate: MapViewDelegate?
    
    private let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 만보기 표시를 위한 라벨 추가
    private let stepCountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stepCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 걸음"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        self.kalmanFilter = OptimizedKalmanFilter(processNoise: 0.01, measurementNoise: 10.0)
        super.init(frame: frame)
        setupMapView()
        setupStepCountView()
        setupLocationManager()
        setupConstraints()
        setupNetworkMonitoring()
        setupMotionFusion()
        setupAdvancedStepTracking()
        
    }
    
    required init?(coder: NSCoder) {
        self.kalmanFilter = OptimizedKalmanFilter(processNoise: 0.01, measurementNoise: 10.0)
        super.init(coder: coder)
        setupMapView()
        setupStepCountView()
        setupLocationManager()
        setupConstraints()
        setupNetworkMonitoring()
        setupMotionFusion()
        setupAdvancedStepTracking()
    }
    
    // MARK: - 설정 메서드
    private func setupMapView() {
        self.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.mapType = .hybrid
    }
    
    private func setupStepCountView() {
        addSubview(stepCountView)
        stepCountView.addSubview(stepCountLabel)
        
        // 걸음 수 뷰가 맵 위에 오도록 레이어 설정
        stepCountView.layer.zPosition = 1000
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        
        // 최고 정확도 설정
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // 백그라운드 위치 업데이트 설정
        locationManager.allowsBackgroundLocationUpdates = true
        
        // 위치 권한 요청
        locationManager.requestWhenInUseAuthorization()
        
        // 초기 지도 영역 설정 (권한 요청과 별개로)
        setInitialMapRegion()
        
        // 만보기를 위한 모션 권한 설정
        if CMPedometer.isStepCountingAvailable() {
            print("걸음 수 측정 가능")
        } else {
            print("걸음 수 측정 불가")
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.startMonitoring { [weak self] isConnected, connectionType in
            guard let self = self else { return }
            
            self.isOnline = isConnected
            self.connectionType = connectionType
            
            // 오프라인 모드로 전환 시 칼만 필터 환경 설정 변경
            self.kalmanFilter.setEnvironment(isLowAccuracy: !isConnected)
        }
    }
    
    private func setupMotionFusion() {
        motionFusion.startMotionUpdates()
    }
 

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // 걸음 수 뷰 위치 설정 (좌상단)
            stepCountView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepCountView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stepCountView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            stepCountView.heightAnchor.constraint(equalToConstant: 40),
            
            // 걸음 수 라벨 위치 설정
            stepCountLabel.topAnchor.constraint(equalTo: stepCountView.topAnchor),
            stepCountLabel.leadingAnchor.constraint(equalTo: stepCountView.leadingAnchor, constant: 10),
            stepCountLabel.trailingAnchor.constraint(equalTo: stepCountView.trailingAnchor, constant: -10),
            stepCountLabel.bottomAnchor.constraint(equalTo: stepCountView.bottomAnchor)
        ])
    }
    
    deinit {
        networkMonitor.stopMonitoring()
        motionFusion.stopMotionUpdates()
        pedometer.stopUpdates()
        locationManager.stopUpdatingLocation()
    }
    
    private func setInitialMapRegion() {
        // 현재 위치가 있다면 해당 위치를 중심으로, 없다면 서울을 기본값으로 설정
        let initialCoordinate: CLLocationCoordinate2D
        
        if let userLocation = locationManager.location?.coordinate {
            initialCoordinate = userLocation
        } else {
            // 기본값: 서울 중심 (또는 원하는 기본 위치)
            initialCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        }
        
        // 최대한 확대된 지역 설정 (약 200미터 반경)
        let region = MKCoordinateRegion(
            center: initialCoordinate,
            latitudinalMeters: 200,  // 세로 200미터
            longitudinalMeters: 200  // 가로 200미터
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - 지도 타입 변경 메서드
    func changeMapType(_ mapType: MKMapType) {
        mapView.mapType = mapType
    }
    
    // MARK: - 경로 업데이트 메서드
    private func updatePath(with location: CLLocation) {
        // 이상치 검출
        if outlierDetector.isOutlier(location) {
            print("이상치 감지됨, 위치 무시")
            return
        }
        
        // 칼만 필터 적용
        let filteredLocation = kalmanFilter.filter(location: location)

        // 모션 데이터와 융합
        let enhancedLocation = motionFusion.enhanceLocation(filteredLocation)
               
        
        // 새 좌표를 경로에 추가
        let coordinate = filteredLocation.coordinate
        pathCoordinates.append(coordinate)
        
        // 거리 계산 (마지막 좌표에서 현재 좌표까지)
        if pathCoordinates.count > 1 {
            let lastLocation = CLLocation(
                latitude: pathCoordinates[pathCoordinates.count - 2].latitude,
                longitude: pathCoordinates[pathCoordinates.count - 2].longitude
            )
            let distance = enhancedLocation.distance(from: lastLocation)
            totalDistance += distance
        }
        
        // 기존 polyline 제거
        if let existingPolyline = polyline {
            mapView.removeOverlay(existingPolyline)
        }
        
        // 새 polyline 생성 및 추가
        if pathCoordinates.count > 1 {
            polyline = MKPolyline(coordinates: pathCoordinates, count: pathCoordinates.count)
            mapView.addOverlay(polyline!)
        }
        
        // 지도 영역 업데이트 (선택사항)
        if let polyline = polyline {
            mapView.setVisibleMapRect(
                polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                animated: true
            )
        }
    }
    
    // MARK: - 위치 샘플 평균 계산
    private func averageLocations(_ locations: [CLLocation]) -> CLLocation {
        guard !locations.isEmpty else {
            return CLLocation(latitude: 0, longitude: 0)
        }
        
        var totalLat: Double = 0
        var totalLon: Double = 0
        var totalAlt: Double = 0
        var totalHAccuracy: Double = 0
        var totalVAccuracy: Double = 0
        var totalCourse: Double = 0
        var totalSpeed: Double = 0
        
        for location in locations {
            totalLat += location.coordinate.latitude
            totalLon += location.coordinate.longitude
            totalAlt += location.altitude
            totalHAccuracy += location.horizontalAccuracy
            totalVAccuracy += location.verticalAccuracy
            totalCourse += location.course
            totalSpeed += location.speed
        }
        
        let count = Double(locations.count)
        let avgCoordinate = CLLocationCoordinate2D(
            latitude: totalLat / count,
            longitude: totalLon / count
        )
        
        return CLLocation(
            coordinate: avgCoordinate,
            altitude: totalAlt / count,
            horizontalAccuracy: totalHAccuracy / count,
            verticalAccuracy: totalVAccuracy / count,
            course: totalCourse / count,
            speed: totalSpeed / count,
            timestamp: locations.last!.timestamp
        )
    }
    
    // MARK: - 만보기 업데이트 메서드
    func updateStepCount(_ steps: Int) {
        stepCount = steps
        stepCountLabel.text = "\(steps) 걸음"
    }
    
    // MARK: - 위치 추적 메서드
    func startTracking() {
        if isTracking {
            return
        }
        
        isTracking = true
        pathCoordinates.removeAll()
        locationSamples.removeAll()
        kalmanFilter.reset()
        outlierDetector.reset()
        stepCount = 0
        totalDistance = 0
        trackingStartTime = Date()
        updateStepCount(0)
        
        if let existingPolyline = polyline {
            mapView.removeOverlay(existingPolyline)
        }
        
        locationManager.startUpdatingLocation()
        
        // 시작 시간부터 걸음 수 측정 시작
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: trackingStartTime!) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else {
                    print("걸음 수 측정 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    return
                }
                
                // UI 업데이트는 메인 스레드에서
                DispatchQueue.main.async {
                    self.updateStepCount(Int(truncating: data.numberOfSteps))
                }
            }
        }
    }
    
    func stopTracking() {
        if !isTracking {
            return
        }
        
        isTracking = false
        locationManager.stopUpdatingLocation()
        pedometer.stopUpdates()
        
        // 추적 결과 요약 보여주기
        delegate?.showTrackingSummary(distance: totalDistance, steps: stepCount)
    }
}
extension MapView {
    
    // MovementFeedbackSystem을 활용한 개선된 걸음 측정
    func setupAdvancedStepTracking() {
        let movementSystem = MovementFeedbackSystem()
        
        // 실시간 움직임 피드백
        movementSystem.onMovementDetected = { [weak self] intensity in
            DispatchQueue.main.async {
                self?.showMovementFeedback(intensity: intensity)
            }
        }
        
        // 걸음 예측 피드백 (확정되기 전)
        movementSystem.onStepPredicted = { [weak self] in
            DispatchQueue.main.async {
                self?.showPredictedStep()
            }
        }
        
        // 걸음 확정 업데이트
        movementSystem.onStepConfirmed = { [weak self] stepCount in
            DispatchQueue.main.async {
                self?.updateStepCount(stepCount)
                self?.confirmPredictedStep()
            }
        }
        /* 민감도 조정 옵션
         - 빠른 반응 (부정확) : threshold: 0.8, stepInterval: 0.1
         - 정확함 (느린 반응) : threshold: 1.5, stepInterval: 0.5
         - 균형잡힌 (기본값) : threshold: 1.0, stepInterval: 0.2
         */
        movementSystem.adjustSensitivity(threshold: 1.5, stepInterval: 0.5)

        movementSystem.startMonitoring()
    }
    
    // 움직임 강도에 따른 시각적 피드백
    private func showMovementFeedback(intensity: Double) {
        // 걸음 수 라벨의 투명도나 크기로 움직임 표시
        let alpha = 0.7 + (intensity * 0.3)  // 0.7 ~ 1.0
        stepCountView.alpha = alpha
        
        // 또는 배경색 변화
        let greenComponent = 0.3 + (intensity * 0.4)  // 움직임이 클수록 더 밝은 녹색
        stepCountView.backgroundColor = UIColor(red: 0, green: greenComponent, blue: 0, alpha: 0.7)
    }
    
    // 걸음 예측 시 미리 보여주기
    private func showPredictedStep() {
        // 현재 걸음 수 + 1을 반투명하게 표시
        let predictedCount = stepCount + 1
        stepCountLabel.text = "\(stepCount) (+1) 걸음"
        stepCountLabel.alpha = 0.7
    }
    
    // 걸음 확정 시 명확하게 표시
    private func confirmPredictedStep() {
        stepCountLabel.alpha = 1.0
        
        // 확정 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            self.stepCountLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.stepCountLabel.transform = CGAffineTransform.identity
            }
        }
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
}


// MARK: - MKMapViewDelegate
extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .green
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapView: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            
            
            // 위치 권한이 확인된 후에 백그라운드 위치 업데이트 설정
            if UIApplication.shared.backgroundRefreshStatus == .available {
                manager.allowsBackgroundLocationUpdates = true
            }
            
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
            // 정확한 위치 권한 확인 (iOS 14 이상은 기본 지원)
            if manager.accuracyAuthorization == .reducedAccuracy {
                // 정확한 위치가 꺼져 있는 경우, 사용자에게 안내 메시지 표시
                let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                delegate?.presentAlert(
                    title: "정확한 위치 필요",
                    message: "정확한 걷기 경로 추적을 위해 정확한 위치 설정이 필요합니다. 설정에서 '정확한 위치'를 켜주세요.",
                    actions: [settingsAction, cancelAction]
                )
            }
            
        case .denied, .restricted:
            // 사용자에게 위치 권한이 필요함을 알리는 알림 표시
            showPermissionAlert()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert() {
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        delegate?.presentAlert(
            title: "위치 권한 필요",
            message: "걷기 경로를 추적하려면 위치 권한이 필요합니다.",
            actions: [settingsAction, cancelAction]
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isTracking else { return }
        
        // 정지 상태에서는 여러 위치 샘플을 수집하여 평균 계산
        if location.speed < 0.1 {
            locationSamples.append(location)
            if locationSamples.count >= 5 {  // 5개로 감소하여 반응성 향상
                let averagedLocation = averageLocations(locationSamples)
                updatePath(with: averagedLocation)
                locationSamples.removeAll()
            }
        } else {
            // 이동 중일 때는 필터링된 위치 사용
            updatePath(with: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}
