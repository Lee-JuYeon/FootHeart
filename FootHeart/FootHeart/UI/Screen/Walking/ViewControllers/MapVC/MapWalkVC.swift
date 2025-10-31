//
//  MapWalkVC.swift
//  FootHeart
//
//  Created by Jupond on 10/17/25.
//

import UIKit
import MapKit
import Combine

class MapWalkVC : UIViewController {
    
    private let mapView: CustomMapView = {
        let view = CustomMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
   
    private let walkRecordButton : WalkRecordButton = {
        let view = WalkRecordButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    private let walkModeView : WalkModeView = {
        let view = WalkModeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    
    private let walkingChartView : WalkingChartView = {
        let view = WalkingChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let historyButton : UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.setTitle("History", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setDelegates()
        setupGestures()
    }
    
    private var walkVM: WalkingVM?
    private var cancellables = Set<AnyCancellable>()
    func setVM(_ vm : WalkingVM){
        self.walkVM = vm
        bindViewModel()
    }
    
    private func setDelegates(){
        mapView.locationDelegate = self
        walkModeView.eventDelegate = self
        walkRecordButton.eventDelegate = self
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        
        view.addSubview(walkingChartView)
        view.addSubview(walkRecordButton)
        view.addSubview(walkModeView)
        view.addSubview(historyButton)
        
        
                        
        NSLayoutConstraint.activate([
            // Map View
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
           
            walkingChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            walkingChartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            
            
            walkModeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            walkModeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // Walking Start,Stop & Puase & History Button - 하단 중간
            walkRecordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            walkRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            walkRecordButton.heightAnchor.constraint(equalToConstant: 60), // ✅ 추가

            historyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            historyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            historyButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    private func setupGestures() {
       historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)

    }

    
    private var walkHistoryData: [MapWalkingModel] = []
    private var walkHistoryView : WalkHistoryList? = nil
    private func loadHistoryData(){
        
    }
    @objc private func historyButtonTapped() {
        // 1. 샘플 데이터 로드
        loadHistoryData()
        
        // 2. Bottom Sheet 생성
        let bottomSheet = CustomBottomSheetView()
        bottomSheet.modalPresentationStyle = .overFullScreen
        
        // 3. History List 생성
        walkHistoryView = WalkHistoryList()
        
        // 4. 컨텐츠 설정
        bottomSheet.setContentView = { [weak self] contentView in
            guard let self = self else { return }
            
            print("📦 BottomSheet contentView 설정 시작")
            
            // ✅ 순서 중요!
            // 1) 먼저 Sheet View 연결 (이때 setupUI 호출됨)
            self.walkHistoryView?.setSheetView(contentView)
            
            // 2) 그 다음 데이터 설정
            self.walkHistoryView?.mList = self.walkHistoryData
            
            // 3) 콜백 설정
            self.walkHistoryView?.onSelectHistory = { [weak self] model in
              
            }
            
            print("✅ BottomSheet 설정 완료")
        }
        
        // 5. Bottom Sheet 표시
        present(bottomSheet, animated: false)
    }
    

    // ✅ ViewModel 바인딩 추가
    private func bindViewModel() {
        guard let walkVM = walkVM else { return }
        
        // 맵 워킹 데이터 구독
        walkVM.$mapWalkingModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.walkingChartView.updateChartUI(model)
                self?.mapView.updatePath(model.path) // 경로 업데이트
            }
            .store(in: &cancellables)
    }
   
}

extension MapWalkVC: CustomMapViewDelegate {
    
    // 위치 권한 요청 alert view
    func walkMapViewNeedsLocationPermission() {
        let alert = UIAlertController(
            title: "위치 권한 필요",
            message: "지도를 사용하려면 위치 권한이 필요합니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension MapWalkVC : WalkModeViewDelegate {
    func onChangeWalkMode(_ mode: WalkMode) {
        switch mode {
        case WalkMode.WALK:
            walkVM?.changeMapWalkMode(.WALK)
        case WalkMode.RUN:
            walkVM?.changeMapWalkMode(.RUN)
        case WalkMode.BICYCLE:
            walkVM?.changeMapWalkMode(.BICYCLE)
        }
    }
}

extension MapWalkVC : WalkRecordDelegate {
    func onChangeRecordState(_ mode: WalkRecordState) {
        switch mode {
        case .START:
            walkVM?.startMapWalking()
            walkingChartView.startDuration()
            mapView.startTracking()  // 추적 모드 시작
        case .STOP:
            walkVM?.stopMapWalking()
            walkingChartView.stopDuration()
            mapView.stopTracking()  // 추적 모드 중지

            walkVM?.resetMapWalking()
            walkingChartView.resetDuration()
            mapView.clearPath()  // 경로 초기화
        case .PAUSE:
            walkVM?.pauseMapWalking()
            walkingChartView.pauseDuration()
        case .RESUME:
            walkVM?.resumeMapWalking()
            walkingChartView.resumeDuration()  
        }
    }
}
