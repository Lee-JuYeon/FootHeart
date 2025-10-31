//
//  MapView.swift
//  FootHeart
//
//  Created by Jupond on 5/12/25.
//
import UIKit
import MapKit
import CoreLocation

protocol CustomMapViewDelegate: AnyObject {
    func walkMapViewNeedsLocationPermission()
}

class CustomMapView: UIView {
    
    weak var locationDelegate: CustomMapViewDelegate?

    private let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.mapType = .standard
        view.showsUserLocation = true
        view.isZoomEnabled = true
        view.isScrollEnabled = true
        view.isPitchEnabled = true
        view.isRotateEnabled = true
        return view
    }()
    
    // 경로 추적용
    private var pathPolyline: MKPolyline?
    private var startAnnotation: MKPointAnnotation?
    private var endAnnotation: MKPointAnnotation?
    
    // 초기 위치 설정 여부 추적
    private var hasSetInitialLocation = false
    
    // 추적 모드 관리
    private var isTrackingActive = false
        
    // 위치 필터링
    private var lastValidLocation: CLLocation?
    private var locationBuffer: [CLLocation] = []
    private let bufferSize = 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupMapUI()
        setupLocationManager()
        setupGestures()
        setDefaultMapRegion()  // ✅ 기본 위치 설정
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupMapUI()
        setupLocationManager()
        setupGestures()
        setDefaultMapRegion()  // ✅ 기본 위치 설정
    }
    
    private func setupUI() {
        mapView.delegate = self

        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private let locationManager = CLLocationManager()
    private let mapZoomLevel : CLLocationDistance = 50
    private func setupMapUI(){
        guard let userLocation = locationManager.location?.coordinate else {
            return
        }
        
        let region = MKCoordinateRegion(
            center: userLocation,
            latitudinalMeters: mapZoomLevel,
            longitudinalMeters: mapZoomLevel
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    // 기본 지도 영역 설정 (서울 시청)
    private func setDefaultMapRegion() {
        let defaultLocation = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        let region = MKCoordinateRegion(
            center: defaultLocation,
            latitudinalMeters: mapZoomLevel,
            longitudinalMeters: mapZoomLevel
        )
        mapView.setRegion(region, animated: false)
    }
    
    // 사용자 위치로 지도 중심 이동
    private func centerOnUserLocation(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: mapZoomLevel,
            longitudinalMeters: mapZoomLevel
        )
        mapView.setRegion(region, animated: animated)
        hasSetInitialLocation = true
        print("📍 지도 중심을 사용자 위치로 이동: \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    
    private var savedSpan: MKCoordinateSpan? // 줌 레벨 유지하면서 중앙 이동
    // 줌 레벨 유지하면서 중앙 이동
    private func centerOnUserLocationKeepingZoom(_ coordinate: CLLocationCoordinate2D) {
        guard let span = savedSpan else {
            centerOnUserLocation(coordinate, animated: false)
            return
        }
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)
        print("📍 줌 레벨 유지하며 중앙 이동")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5  // 5m마다 업데이트
        locationManager.activityType = .fitness  // 피트니스 활동
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        let status = locationManager.authorizationStatus // 위치 권한 확인
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
            // 이미 위치를 알고 있다면 즉시 중심 이동
            if let location = locationManager.location?.coordinate {
                centerOnUserLocation(location)
            }
        case .denied, .restricted:
            showLocationPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func setupGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        let currentSpan = mapView.region.span
        let newSpan = MKCoordinateSpan(
            latitudeDelta: currentSpan.latitudeDelta / 2.0,
            longitudeDelta: currentSpan.longitudeDelta / 2.0
        )
        
        let region = MKCoordinateRegion(center: coordinate, span: newSpan)
        mapView.setRegion(region, animated: true)
    }
    
    // 추적 시작
    func startTracking() {
        isTrackingActive = true
        
        // ✅ 현재 줌 레벨 저장
        savedSpan = mapView.region.span
        print("💾 현재 줌 레벨 저장: latDelta=\(savedSpan?.latitudeDelta ?? 0), lonDelta=\(savedSpan?.longitudeDelta ?? 0)")
        
        // ✅ 사용자 위치 추적 모드 비활성화 (수동으로 관리)
        mapView.userTrackingMode = .none
        
        locationBuffer.removeAll()
        lastValidLocation = nil
        
        // ✅ 현재 위치로 중앙 이동 (줌 레벨 유지)
        if let location = locationManager.location?.coordinate {
            centerOnUserLocationKeepingZoom(location)
        }
                
        print("🎯 사용자 추적 모드 시작")
    }
    
    // 추적 중지
    func stopTracking() {
        isTrackingActive = false
        savedSpan = nil
        
        print("⏹️ 사용자 추적 모드 종료")
    }
    
    // 위치 유효성 검사
    private func isValidLocation(_ location: CLLocation) -> Bool {
        // 1. 정확도 체크 (실내: 65m 이상, 실외: 20m 이하가 이상적)
        guard location.horizontalAccuracy > 0 && location.horizontalAccuracy < 100 else {
            print("❌ 정확도 낮음: \(Int(location.horizontalAccuracy))m")
            return false
        }
        
        // 2. 속도 체크 (보행: 0~3 m/s)
        if location.speed > 0 && location.speed > 3.0 {
            print("❌ 비정상 속도: \(String(format: "%.1f", location.speed))m/s")
            return false
        }
        
        // 3. 위치 점프 감지
        if let lastLoc = lastValidLocation {
            let distance = location.distance(from: lastLoc)
            let timeInterval = location.timestamp.timeIntervalSince(lastLoc.timestamp)
            
            guard timeInterval > 0 else { return false }
            
            let calculatedSpeed = distance / timeInterval
            
            // 급격한 이동 감지 (10m/s = 36km/h 이상)
            if calculatedSpeed > 10.0 {
                print("❌ 위치 점프 감지: \(Int(distance))m in \(String(format: "%.1f", timeInterval))s")
                return false
            }
        }
        
        return true
    }
    
    // 실내 감지
    private func isIndoorLocation(_ location: CLLocation) -> Bool {
        // 실내에서는 GPS 정확도가 크게 떨어짐 (보통 65m 이상)
        return location.horizontalAccuracy > 65
    }
    
    // 위치 평활화 (버퍼 사용)
    private func smoothLocation(_ location: CLLocation) -> CLLocation? {
        locationBuffer.append(location)
        
        if locationBuffer.count > bufferSize {
            locationBuffer.removeFirst()
        }
        
        // 버퍼가 충분히 차지 않았으면 대기
        guard locationBuffer.count >= bufferSize else {
            return nil
        }
        
        // 평균 위치 계산
        var totalLat = 0.0
        var totalLon = 0.0
        
        for loc in locationBuffer {
            totalLat += loc.coordinate.latitude
            totalLon += loc.coordinate.longitude
        }
        
        let avgLat = totalLat / Double(locationBuffer.count)
        let avgLon = totalLon / Double(locationBuffer.count)
        
        return CLLocation(
            latitude: avgLat,
            longitude: avgLon
        )
    }
    
    // 이동 경로 업데이트 (MapWalkingModel의 path 사용)
    func updatePath(_ path: [MapWalkingModel.LocationData]) {
        // 기존 경로 제거
        if let oldPolyline = pathPolyline {
            mapView.removeOverlay(oldPolyline)
        }
        
        // 경로가 없으면 종료
        guard !path.isEmpty else { return }
        
        // LocationData를 CLLocationCoordinate2D로 변환
        let coordinates = path.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        // 새 polyline 생성 및 추가
        if coordinates.count > 1 {
            pathPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(pathPolyline!)
            
            // 시작/종료 핀 업데이트
            updateStartEndAnnotations(start: coordinates.first!, end: coordinates.last!)
            
            // 추적 모드가 아닐 때만 경로에 맞춰 줌
            if !isTrackingActive {
                let rect = pathPolyline!.boundingMapRect
                let insets = UIEdgeInsets(top: 80, left: 50, bottom: 80, right: 50)
                mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
            }
        }
    }
    
    // 시작/종료 지점 핀 업데이트
    private func updateStartEndAnnotations(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        // 기존 핀 제거
        if let oldStart = startAnnotation {
            mapView.removeAnnotation(oldStart)
        }
        if let oldEnd = endAnnotation {
            mapView.removeAnnotation(oldEnd)
        }
        
        // 시작 지점 핀 (파란색)
        let startPin = MKPointAnnotation()
        startPin.coordinate = start
        startPin.title = "시작"
        startAnnotation = startPin
        mapView.addAnnotation(startPin)
        
        // 종료 지점 핀 (빨간색)
        let endPin = MKPointAnnotation()
        endPin.coordinate = end
        endPin.title = "현재 위치"
        endAnnotation = endPin
        mapView.addAnnotation(endPin)
    }
    
    // 경로 초기화
    func clearPath() {
        // 경로 제거
        if let oldPolyline = pathPolyline {
            mapView.removeOverlay(oldPolyline)
            pathPolyline = nil
        }
        
        // 핀 제거
        if let oldStart = startAnnotation {
            mapView.removeAnnotation(oldStart)
            startAnnotation = nil
        }
        if let oldEnd = endAnnotation {
            mapView.removeAnnotation(oldEnd)
            endAnnotation = nil
        }
        
        // 경로 초기화 후 사용자 위치로 다시 중심 이동
        if let location = locationManager.location?.coordinate {
            centerOnUserLocation(location)
        }
    }
    
    private func showLocationPermissionAlert() {
        locationDelegate?.walkMapViewNeedsLocationPermission()
    }
}

extension CustomMapView: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            
            // 권한 승인 직후 위치 확인
            if let location = locationManager.location?.coordinate {
                centerOnUserLocation(location)
            }
            
        case .denied, .restricted:
            showLocationPermissionAlert()
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
                
        // ✅ 위치 유효성 검사
        guard isValidLocation(location) else {
            return
        }
        
        // ✅ 실내 감지
        if isIndoorLocation(location) {
            print("🏢 실내 위치 감지 - 정확도: \(Int(location.horizontalAccuracy))m")
        }
        
        // ✅ 위치 평활화
        if let smoothed = smoothLocation(location) {
            lastValidLocation = smoothed
                       
            // ✅ 추적 모드일 때 계속 중앙에 위치 (줌 레벨 유지)
            if isTrackingActive {
                centerOnUserLocationKeepingZoom(smoothed.coordinate)
            }
        }
        
        // ✅ 첫 위치 설정
        if !hasSetInitialLocation {
            centerOnUserLocation(location.coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 업데이트 실패: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate
extension CustomMapView: MKMapViewDelegate {
    
    // 사용자 위치가 업데이트될 때마다 호출됨
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // 사용자 위치가 처음 업데이트될 때 중심 이동
        guard !hasSetInitialLocation,
              let coordinate = userLocation.location?.coordinate else {
            return
        }
        
        centerOnUserLocation(coordinate, animated: true)
    }
    
    // ✅ Annotation 커스터마이징 (시작/종료 핀 색상)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자 위치는 기본 스타일 사용
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "PinAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // 시작 지점: 파란색
        if annotation.title == "시작" {
            annotationView?.markerTintColor = .systemBlue
            annotationView?.glyphImage = UIImage(systemName: "figure.walk")
        }
        // 종료 지점: 빨간색
        else if annotation.title == "현재 위치" {
            annotationView?.markerTintColor = .systemRed
            annotationView?.glyphImage = UIImage(systemName: "flag.fill")
        }
        
        return annotationView
    }
    
    // olyline 렌더링 (초록색 경로)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemGreen  // ✅ 초록색
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
