//
//  ViewController.swift
//  FootHeart
//
//  Created by Jupond on 5/11/25.
//

import UIKit
import CoreLocation
import MapKit

class WalkingViewController: UIViewController {
    private let mapView: MapView = {
        let view = MapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 추적 상태 관리를 위한 속성들
    private var isTracking = false
    private var trackingStartTime: Date?
    
    // 버튼 참조를 위한 속성들
    private weak var startButton: UIButton?
    private weak var stopButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupButtons()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 숨기기 (선택사항)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        mapView.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "걷기 추적"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 네비게이션 바에 상태 표시 (선택사항)
        let statusItem = UIBarButtonItem(title: "준비", style: .plain, target: nil, action: nil)
        statusItem.isEnabled = false
        navigationItem.rightBarButtonItem = statusItem
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
      
    private func setupButtons() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 15
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 시작 버튼
        let startButton = createButton(
            title: "시작",
            backgroundColor: .systemGreen,
            action: #selector(startButtonTapped)
        )
        self.startButton = startButton
        
        // 정지 버튼
        let stopButton = createButton(
            title: "정지",
            backgroundColor: .systemRed,
            action: #selector(stopButtonTapped)
        )
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        self.stopButton = stopButton
        
        // 지도 타입 버튼
        let mapTypeButton = createButton(
            title: "지도타입",
            backgroundColor: .systemBlue,
            action: #selector(mapTypeButtonTapped)
        )
        
        buttonStackView.addArrangedSubview(startButton)
        buttonStackView.addArrangedSubview(stopButton)
        buttonStackView.addArrangedSubview(mapTypeButton)
    }
    
    private func createButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func startButtonTapped() {
        // 이미 추적 중이면 중복 실행 방지
        guard !isTracking else { return }
        
        isTracking = true
        trackingStartTime = Date()
        
        // 버튼 상태 업데이트
        updateButtonStates()
        
        // 네비게이션 바 상태 업데이트
        navigationItem.rightBarButtonItem?.title = "추적 중"
        
        // 추적 시작
        mapView.startTracking()
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        print("추적 시작됨")
    }
    
    @objc private func stopButtonTapped() {
        // 추적 중이 아니면 실행하지 않음
        guard isTracking else { return }
        
        // 사용자 확인 알림
        let confirmAlert = UIAlertController(
            title: "추적 정지",
            message: "걷기 추적을 정지하시겠습니까?",
            preferredStyle: .alert
        )
        
        confirmAlert.addAction(UIAlertAction(title: "계속", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "정지", style: .destructive) { [weak self] _ in
            self?.stopTracking()
        })
        
        present(confirmAlert, animated: true)
    }
    
    private func stopTracking() {
        isTracking = false
        
        // 버튼 상태 업데이트
        updateButtonStates()
        
        // 네비게이션 바 상태 업데이트
        navigationItem.rightBarButtonItem?.title = "완료"
        
        // 추적 정지
        mapView.stopTracking()
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        print("추적 정지됨")
    }
    
    private func updateButtonStates() {
        UIView.animate(withDuration: 0.3) {
            if self.isTracking {
                // 추적 중: 시작 버튼 비활성화, 정지 버튼 활성화
                self.startButton?.isEnabled = false
                self.startButton?.alpha = 0.5
                self.stopButton?.isEnabled = true
                self.stopButton?.alpha = 1.0
            } else {
                // 대기 중: 시작 버튼 활성화, 정지 버튼 비활성화
                self.startButton?.isEnabled = true
                self.startButton?.alpha = 1.0
                self.stopButton?.isEnabled = false
                self.stopButton?.alpha = 0.5
            }
        }
    }
    
    @objc private func mapTypeButtonTapped() {
        let actionSheet = UIAlertController(title: "지도 타입 선택", message: "원하는 지도 스타일을 선택하세요", preferredStyle: .actionSheet)
        
        // 지도 타입 옵션들
        let mapTypes: [(title: String, type: MKMapType)] = [
            ("표준", .standard),
            ("위성", .satellite),
            ("하이브리드", .hybrid),
            ("위성 플라이오버", .satelliteFlyover),
            ("하이브리드 플라이오버", .hybridFlyover)
        ]
        
        for (title, type) in mapTypes {
            actionSheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.mapView.changeMapType(type)
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad 대응
        if let popoverController = actionSheet.popoverPresentationController {
            if let mapTypeButton = view.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.last as? UIButton {
                popoverController.sourceView = mapTypeButton
                popoverController.sourceRect = mapTypeButton.bounds
            } else {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        present(actionSheet, animated: true)
    }
}

// MARK: - MapViewDelegate
extension WalkingViewController: MapViewDelegate {
    func presentAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
    
    func showTrackingSummary(distance: Double, steps: Int) {
        // 추적 시간 계산
        let trackingDuration: TimeInterval
        if let startTime = trackingStartTime {
            trackingDuration = Date().timeIntervalSince(startTime)
        } else {
            trackingDuration = 0
        }
        
        // 시간 포맷팅
        let hours = Int(trackingDuration) / 3600
        let minutes = Int(trackingDuration) % 3600 / 60
        let seconds = Int(trackingDuration) % 60
        
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        // 거리 포맷팅 (미터 -> 킬로미터)
        let distanceString: String
        if distance >= 1000 {
            distanceString = String(format: "%.2f km", distance / 1000)
        } else {
            distanceString = String(format: "%.0f m", distance)
        }
        
        // 평균 속도 계산 (km/h)
        let averageSpeed = trackingDuration > 0 ? (distance / 1000) / (trackingDuration / 3600) : 0
        let speedString = String(format: "%.1f km/h", averageSpeed)
        
        // 요약 메시지 생성
        let summaryMessage = """
        🚶‍♂️ 걸음 수: \(steps)걸음
        📏 이동 거리: \(distanceString)
        ⏱️ 소요 시간: \(timeString)
        🏃‍♂️ 평균 속도: \(speedString)
        """
        
        let summaryAlert = UIAlertController(
            title: "걷기 추적 완료",
            message: summaryMessage,
            preferredStyle: .alert
        )
        
        // 새로 시작 버튼
        summaryAlert.addAction(UIAlertAction(title: "새로 시작", style: .default) { [weak self] _ in
            self?.startButtonTapped()
        })
        
        // 확인 버튼
        summaryAlert.addAction(UIAlertAction(title: "확인", style: .cancel) { [weak self] _ in
            // 추적 완료 후 상태 초기화
            self?.trackingStartTime = nil
            self?.navigationItem.rightBarButtonItem?.title = "준비"
        })
        
        present(summaryAlert, animated: true)
        
        // 성취 햅틱 피드백
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(.success)
    }
}
