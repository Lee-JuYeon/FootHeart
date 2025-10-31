//
//  WalkMapView.swift
//  FootHeart
//
//  Created by Jupond on 10/26/25.
//
//
//import UIKit
//import MapKit
//import CoreLocation
//
//protocol WalkMapViewDelegate: AnyObject {
//    func walkMapViewNeedsLocationPermission()
//}
//
//class WalkMapView: UIView {
//    
//    weak var locationDelegate: WalkMapViewDelegate?
//
//    private let mapView: MKMapView = {
//        let view = MKMapView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.mapType = .standard
//        view.showsUserLocation = true
//        view.isZoomEnabled = true
//        view.isScrollEnabled = true
//        view.isPitchEnabled = true
//        view.isRotateEnabled = true
//        return view
//    }()
//    
//    // MARK: - Initialization
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//        setupMapUI()
//        setupLocationManager()
//        setupGestures()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//        setupUI()
//        setupMapUI()
//        setupLocationManager()
//        setupGestures()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupUI() {
//        mapView.delegate = self
//
//        addSubview(mapView)
//        NSLayoutConstraint.activate([
//            mapView.topAnchor.constraint(equalTo: topAnchor),
//            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//    }
//    
//    private let locationManager = CLLocationManager()
//    private func setupMapUI(){
//        guard let userLocation = locationManager.location?.coordinate else {
//            return
//        }
//        
//        let region = MKCoordinateRegion(
//            center: userLocation,
//            latitudinalMeters: 500,
//            longitudinalMeters: 500
//        )
//        
//        mapView.setRegion(region, animated: true)
//    }
//    
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//    
//    private func setupGestures() {
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTapGesture.numberOfTapsRequired = 2
//        mapView.addGestureRecognizer(doubleTapGesture)
//    }
//    
//    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//        let point = gesture.location(in: mapView)
//        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
//        
//        let currentSpan = mapView.region.span
//        let newSpan = MKCoordinateSpan(
//            latitudeDelta: currentSpan.latitudeDelta / 2.0,
//            longitudeDelta: currentSpan.longitudeDelta / 2.0
//        )
//        
//        let region = MKCoordinateRegion(center: coordinate, span: newSpan)
//        mapView.setRegion(region, animated: true)
//    }
//    
//
//    func displayPath(_ path: [CLLocation]) {
//        mapView.removeOverlays(mapView.overlays)
//        
//        let coordinates = path.map { $0.coordinate }
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//        
//        mapView.addOverlay(polyline)
//        
//        let rect = polyline.boundingMapRect
//        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
//    }
//    
//    private func showLocationPermissionAlert() {
//        locationDelegate?.walkMapViewNeedsLocationPermission()
//    }
//}
//
//extension WalkMapView: CLLocationManagerDelegate {
//    
// 
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:
//            locationManager.startUpdatingLocation()
//            mapView.showsUserLocation = true
//            
//            // 사용자 위치로 지도 이동
//            if let location = locationManager.location?.coordinate {
//                let region = MKCoordinateRegion(
//                    center: location,
//                    latitudinalMeters: 500,
//                    longitudinalMeters: 500
//                )
//                mapView.setRegion(region, animated: true)
//            }
//            
//        case .denied, .restricted:
//            showLocationPermissionAlert()
//            
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//            
//        @unknown default:
//            break
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        // 필요한 경우 위치 업데이트 처리
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("위치 업데이트 실패: \(error.localizedDescription)")
//    }
//    
//}
//
//// MARK: - MKMapViewDelegate
//extension WalkMapView: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        // 사용자 위치가 업데이트될 때마다 호출됨
//    }
//    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        // 사용자 위치 커스터마이징
//        if annotation is MKUserLocation {
//            let identifier = "UserLocation"
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            
//            if annotationView == nil {
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                
//                // 커스텀 이미지 사용
//                annotationView?.image = UIImage(systemName: "person.circle.fill")
//                annotationView?.tintColor = .systemYellow
//                
//                // 또는 핀 스타일 사용
//                // let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                // pinView.pinTintColor = .systemBlue
//                // return pinView
//            }
//            
//            return annotationView
//        }
//        
//        // 커스텀 어노테이션 뷰 설정 (필요한 경우)
//        return nil
//    }
//}
//
