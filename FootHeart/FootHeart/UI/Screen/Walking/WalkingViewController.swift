//
//  ViewController.swift
//  FootHeart
//
//  Created by Jupond on 5/11/25.
//import UIKit
import CoreLocation
import MapKit
import Combine

class WalkingViewController: UIViewController {
    
    private let dailyStepCountLabel: StepCountLabel = {
        let view = StepCountLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dailyKcalBurningView: KcalBurningLabel = {
        let view = KcalBurningLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let walkingVM: WalkingVM
    private var cancellables = Set<AnyCancellable>()
    init(walkingVM: WalkingVM) {
        self.walkingVM = walkingVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabLayout()
        setupViews()
        setupConstraints()
        bindViewModel()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    private var tabLayout: TabLayout?
    private let mapWalkVC = MapWalkVC()
    private let themeWalkVC = ThemeWalkVC()
    private let audioWalkVC = AudioWalkVC()
    private func setupTabLayout() {
        mapWalkVC.setVM(walkingVM)
        
        let layout = TabLayout()
        layout.translatesAutoresizingMaskIntoConstraints = false
        
        // TabLayout 설정
        layout.setParentVC(self)
        layout.setTabList([
            TabModel(title: "지도 걷기"),
            TabModel(title: "테마 걷기"),
            TabModel(title: "오디오 걷기")
        ])
        layout.setControllers([mapWalkVC, themeWalkVC, audioWalkVC])
        
        tabLayout = layout
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
                
        view.addSubview(dailyStepCountLabel)
        view.addSubview(dailyKcalBurningView)
        
        if let tabLayout = tabLayout {
            view.addSubview(tabLayout)
        }
    }
    
    private func setupConstraints() {
        guard let tabLayout = tabLayout else { return }
        
        NSLayoutConstraint.activate([
            // Daily Walking View
            dailyStepCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dailyStepCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            // Kcal Burning View
            dailyKcalBurningView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dailyKcalBurningView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Tab Layout
            tabLayout.topAnchor.constraint(equalTo: dailyStepCountLabel.bottomAnchor, constant: 20),
            tabLayout.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabLayout.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabLayout.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private let juyeonBMIModel = BMIModel(
        weight: 143,
        steps: 0,               // 칼로리 변환 보정값
        strideLength: nil,      // 보폭
        fatMass: 77.14,         // 체지방량
        leanMass: 70.5,         // 제지방량
        muscleMass: 65.64,      // 근육량
        fatPercent: 52.3,       // 체지방률
        bmr: 1890,              // 기초 대사량
        age: 32,                // 나이
        visceralFatIndex: 35,   // 내장지방지수
        height: 173,            // 키
        isWomen: false          // 성별
    )
    
    // MARK: - Binding
    private func bindViewModel() {
        walkingVM.$dailyWalkingModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mapWalkingModel in
                guard let self = self else { return }
                self.updateUI(with: mapWalkingModel)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with model: MapWalkingModel) {
        dailyKcalBurningView.updateKcal(model, bmiModel: juyeonBMIModel)
        dailyStepCountLabel.stepCount = model.steps
    }
}



//
//class WalkingViewController: UIViewController {
//    
//
//    private let mapView: MapView = {
//        let view = MapView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let abTestTableView: WalkingRecordListView = {
//        let tableView = WalkingRecordListView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
//    
//    private let walkingVM: WalkingVM
//    init(walkingVM: WalkingVM) {
//        self.walkingVM = walkingVM
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private var isWalking = false
//    private var walkingStartDate: Date?
//    private var walkingEndDate: Date?
//    private var currentRoute: [CLLocationCoordinate2D] = []
//    private var autoStepCount = 0
//    private var totalDistance: Double = 0.0
//      
//    
//    
//    // 추적 상태 관리를 위한 속성들
//    private var isTracking = false
//    private var trackingStartTime: Date?
//    
//    // 버튼 참조를 위한 속성들
//    private weak var startButton: UIButton?
//    private weak var stopButton: UIButton?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupViews()
//        setupButtons()
//        setupNavigationBar()
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // 네비게이션 바 숨기기 (선택사항)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//
//    private func setupViews() {
//        view.backgroundColor = .systemBackground
//        view.addSubview(mapView)
//        view.addSubview(abTestTableView)
//        
//        mapView.delegate = self
//        abTestTableView.delegate = self
//        
//        NSLayoutConstraint.activate([
//            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),  // ✅ StatusBar 아래부터
//            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mapView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),  // ✅ SafeArea 기준
//            
//            // WalkingTableView - 하단 절반
//            abTestTableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
//            abTestTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            abTestTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            abTestTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    private func setupNavigationBar() {
////        title = "걷기"
//        navigationController?.navigationBar.prefersLargeTitles = true
//        
//        // 네비게이션 바에 상태 표시 (선택사항)
//        let statusItem = UIBarButtonItem(title: "준비", style: .plain, target: nil, action: nil)
//        statusItem.isEnabled = false
//        navigationItem.rightBarButtonItem = statusItem
//    }
//    
//    private func setupButtons() {
//        let buttonStackView = UIStackView()
//        buttonStackView.axis = .horizontal
//        buttonStackView.distribution = .fillEqually
//        buttonStackView.spacing = 15
//        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(buttonStackView)
//        
//        NSLayoutConstraint.activate([
//            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            // ✅ SafeArea bottom 대신 TabBar 위로 설정
//            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
//            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
//        ])
//
//        // 시작 버튼
//        let startButton = createButton(
//            title: "시작",
//            backgroundColor: .systemGreen,
//            action: #selector(startButtonTapped)
//        )
//        self.startButton = startButton
//        
//        // 정지 버튼
//        let stopButton = createButton(
//            title: "정지",
//            backgroundColor: .systemRed,
//            action: #selector(stopButtonTapped)
//        )
//        stopButton.isEnabled = false
//        stopButton.alpha = 0.5
//        self.stopButton = stopButton
//        
//        // 지도 타입 버튼
//        let mapTypeButton = createButton(
//            title: "지도타입",
//            backgroundColor: .systemBlue,
//            action: #selector(mapTypeButtonTapped)
//        )
//        
//        buttonStackView.addArrangedSubview(startButton)
//        buttonStackView.addArrangedSubview(stopButton)
//        buttonStackView.addArrangedSubview(mapTypeButton)
//    }
//    
//  
//    
//    
//    private func createButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.backgroundColor = backgroundColor
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        button.layer.cornerRadius = 12
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowOpacity = 0.1
//        button.layer.shadowRadius = 4
//        button.addTarget(self, action: action, for: .touchUpInside)
//        return button
//    }
//    
//    @objc private func startButtonTapped() {
//        // 이미 추적 중이면 중복 실행 방지
//        guard !isTracking else { return }
//        
//        isTracking = true
//        trackingStartTime = Date()
//        
//        // 버튼 상태 업데이트
//        updateButtonStates()
//        
//        // 네비게이션 바 상태 업데이트
//        navigationItem.rightBarButtonItem?.title = "추적 중"
//        
//        // 추적 시작
//        mapView.startTracking()
//        
//        // 햅틱 피드백
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        impactGenerator.impactOccurred()
//        
//        print("추적 시작됨")
//    }
//    
//    @objc private func stopButtonTapped() {
//        // 추적 중이 아니면 실행하지 않음
//        guard isTracking else { return }
//        
//        // 사용자 확인 알림
//        let confirmAlert = UIAlertController(
//            title: "추적 정지",
//            message: "걷기 추적을 정지하시겠습니까?",
//            preferredStyle: .alert
//        )
//        
//        confirmAlert.addAction(UIAlertAction(title: "계속", style: .cancel))
//        confirmAlert.addAction(UIAlertAction(title: "정지", style: .destructive) { [weak self] _ in
//            self?.stopTracking()
//        })
//        
//        present(confirmAlert, animated: true)
//    }
//    
//    private func stopTracking() {
//        isTracking = false
//        
//        // 버튼 상태 업데이트
//        updateButtonStates()
//        
//        // 네비게이션 바 상태 업데이트
//        navigationItem.rightBarButtonItem?.title = "완료"
//        
//        // 추적 정지
//        mapView.stopTracking()
//        
//        // 햅틱 피드백
//        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
//        impactGenerator.impactOccurred()
//        
//        print("추적 정지됨")
//    }
//    
//    private func updateButtonStates() {
//        UIView.animate(withDuration: 0.3) {
//            if self.isTracking {
//                // 추적 중: 시작 버튼 비활성화, 정지 버튼 활성화
//                self.startButton?.isEnabled = false
//                self.startButton?.alpha = 0.5
//                self.stopButton?.isEnabled = true
//                self.stopButton?.alpha = 1.0
//            } else {
//                // 대기 중: 시작 버튼 활성화, 정지 버튼 비활성화
//                self.startButton?.isEnabled = true
//                self.startButton?.alpha = 1.0
//                self.stopButton?.isEnabled = false
//                self.stopButton?.alpha = 0.5
//            }
//        }
//    }
//    
//    @objc private func mapTypeButtonTapped() {
//        let actionSheet = UIAlertController(title: "지도 타입 선택", message: "원하는 지도 스타일을 선택하세요", preferredStyle: .actionSheet)
//        
//        // 지도 타입 옵션들
//        let mapTypes: [(title: String, type: MKMapType)] = [
//            ("표준", .standard),
//            ("위성", .satellite),
//            ("하이브리드", .hybrid),
//            ("위성 플라이오버", .satelliteFlyover),
//            ("하이브리드 플라이오버", .hybridFlyover)
//        ]
//        
//        for (title, type) in mapTypes {
//            actionSheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
//                self?.mapView.changeMapType(type)
//            })
//        }
//        
//        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
//        
//        // iPad 대응
//        if let popoverController = actionSheet.popoverPresentationController {
//            if let mapTypeButton = view.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.last as? UIButton {
//                popoverController.sourceView = mapTypeButton
//                popoverController.sourceRect = mapTypeButton.bounds
//            } else {
//                popoverController.sourceView = view
//                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
//                popoverController.permittedArrowDirections = []
//            }
//        }
//        
//        present(actionSheet, animated: true)
//    }
//}
//
//extension WalkingViewController : WalkingABTest {
//    
//    // 테이블뷰에서 걷기 시작 버튼이 눌렸을 때
//    func walkingRecordDidStartWalking(_ tableView: WalkingRecordListView) {
//       
//        // 메인 컨트롤러의 시작 버튼과 동일한 동작 수행
//        startButtonTapped()
//    }
//    
//    // 테이블뷰에서 걷기 종료 버튼이 눌렸을 때
//    func walkingRecordDidStopWalking(_ tableView: WalkingRecordListView) {
//       
//        // 메인 컨트롤러의 정지 버튼과 동일한 동작 수행
//        stopButtonTapped()
//    }
//    
//    // 수동 걸음수 카운트 버튼이 눌렸을 때
//    func walkingRecordDidTapManualStep(_ tableView: WalkingRecordListView) {
//       
////        guard isTracking else {
////            // 추적 중이 아니면 알림 표시
////            showAlert(title: "알림", message: "걷기 추적을 시작한 후 수동 카운트를 사용할 수 있습니다.")
////            return
////        }
////        
////        walkingvm.updateWalkingCount()
////        // 수동 걸음수 증가
////        manualStepCount += 1
////        
////        // 테이블뷰 헤더 업데이트
////        tableView.updateList(
////            isWalking: isTracking,
////            autoStepCount: autoStepCount,
////            manualStepCount: manualStepCount
////        )
////        
////        // 햅틱 피드백
////        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
////        impactGenerator.impactOccurred()
////        
////        print("수동 걸음수 증가: \(manualStepCount)")
//    }
//    
//    func onCellClick(_ tableView: WalkingRecordListView, didSelectRecord record: WalkingRecordModel, at index: Int) {
//        // 걷기 기록 셀이 선택되었을 때 상세 정보 표시
////        showWalkingRecordDetail(record: record)
//    }
//    
//    func onDeleteModel(_ listView: WalkingRecordListView, didDeleteRecord record: WalkingRecordModel, at index: Int) {
//        // 걷기 기록이 삭제되었을 때
//        print("걷기 기록 삭제됨: \(record.formattedDate) - \(record.formattedDistance)")
//        
//        // 삭제 완료 햅틱 피드백
//        let notificationGenerator = UINotificationFeedbackGenerator()
//        notificationGenerator.notificationOccurred(.success)
//        
//        // 필요시 추가 로직 (예: 서버 동기화, 로컬 저장소 업데이트 등)
//        // UserDefaults나 Core Data에서도 삭제하는 로직을 여기에 추가
//    }
//    
//    func walkingRecordListViewDidRequestExportRecords(_ listView: WalkingRecordListView, records: [WalkingRecordModel]) {
//        // 걷기 기록 내보내기 요청
////        exportWalkingRecords(records)
//    }
//    
//    
//}
//
//// MARK: - MapViewDelegate
//extension WalkingViewController : MapViewDelegate {
//    func presentAlert(title: String, message: String, actions: [UIAlertAction]) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        for action in actions {
//            alertController.addAction(action)
//        }
//        present(alertController, animated: true)
//    }
//    
//    func showTrackingSummary(distance: Double, steps: Int) {
//        // 추적 시간 계산
//        let trackingDuration: TimeInterval
//        if let startTime = trackingStartTime {
//            trackingDuration = Date().timeIntervalSince(startTime)
//        } else {
//            trackingDuration = 0
//        }
//        
//        // 시간 포맷팅
//        let hours = Int(trackingDuration) / 3600
//        let minutes = Int(trackingDuration) % 3600 / 60
//        let seconds = Int(trackingDuration) % 60
//        
//        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//        
//        // 거리 포맷팅 (미터 -> 킬로미터)
//        let distanceString: String
//        if distance >= 1000 {
//            distanceString = String(format: "%.2f km", distance / 1000)
//        } else {
//            distanceString = String(format: "%.0f m", distance)
//        }
//        
//        // 평균 속도 계산 (km/h)
//        let averageSpeed = trackingDuration > 0 ? (distance / 1000) / (trackingDuration / 3600) : 0
//        let speedString = String(format: "%.1f km/h", averageSpeed)
//        
//        // 요약 메시지 생성
//        let summaryMessage = """
//        🚶‍♂️ 걸음 수: \(steps)걸음
//        📏 이동 거리: \(distanceString)
//        ⏱️ 소요 시간: \(timeString)
//        🏃‍♂️ 평균 속도: \(speedString)
//        """
//        
//        let summaryAlert = UIAlertController(
//            title: "걷기 추적 완료",
//            message: summaryMessage,
//            preferredStyle: .alert
//        )
//        
//        // 새로 시작 버튼
//        summaryAlert.addAction(UIAlertAction(title: "새로 시작", style: .default) { [weak self] _ in
//            self?.startButtonTapped()
//        })
//        
//        // 확인 버튼
//        summaryAlert.addAction(UIAlertAction(title: "확인", style: .cancel) { [weak self] _ in
//            // 추적 완료 후 상태 초기화
//            self?.trackingStartTime = nil
//            self?.navigationItem.rightBarButtonItem?.title = "준비"
//        })
//        
//        present(summaryAlert, animated: true)
//        
//        // 성취 햅틱 피드백
//        let notificationGenerator = UINotificationFeedbackGenerator()
//        notificationGenerator.notificationOccurred(.success)
//    }
//}
