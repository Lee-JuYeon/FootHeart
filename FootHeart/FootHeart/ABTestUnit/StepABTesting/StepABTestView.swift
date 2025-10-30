//
//  WalkingTableViewDelegate.swift
//  FootHeart
//
//  Created by Jupond on 6/18/25.
//
import UIKit
import Combine

class StepABTestView : UIView {
    
    var dataList : [StepABTestModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    private let stepCheckerButton : StepCheckerButton = {
        let view = StepCheckerButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stepABTestButton: StepABTestButton = {
        let view = StepABTestButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let abTestVM: ABTestVM
    private var cancellables = Set<AnyCancellable>()
    
    init(abTestVM: ABTestVM) {
        self.abTestVM = abTestVM
        super.init(frame: .zero)
        setupUI()
        setupTableView()
        setupActions()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(headerView)
        addSubview(tableView)
        
        headerView.addSubview(stepCheckerButton)
        headerView.addSubview(stepABTestButton)
        
        NSLayoutConstraint.activate([
            // Header View (상단 고정)
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Left Button
            stepCheckerButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stepCheckerButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Right Button
            stepABTestButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stepABTestButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StepABTestCell.self, forCellReuseIdentifier: StepABTestCell.identifier)
    }
    
    
    // 헤더 버튼 액션 클로저
    private var walkingStartDate: Date?
    private var isWalking : Bool = false
    private func setupActions() {
        
        // 걷기 시작 버튼 눌림
        stepABTestButton.onWalkingStart = { [weak self] in
            guard let self = self else { return }
            walkingStartDate = Date()
        
            isWalking = true
            abTestVM.startMonitoringStepABTest()
        }
        
        // 걷기 종료 버튼 눌림
        stepABTestButton.onWalkingStop = { [weak self] in
            guard let self = self else { return }
            guard let startDate = walkingStartDate else {
                print("걷기 시작 기록이 없습니다.")
                return
            }
   
            // StepABTestModel 생성
            let model = StepABTestModel(
                manualStepCount: stepCheckerButton.getStepCount(),
                autoStepCount: abTestVM.abTestWalkingModel.autoStepCount,
                autoStepPath: [],
                date: startDate
            )
            
            // dataList에 추가 (최신 데이터가 위로)
            dataList.insert(model, at: 0)
        
            // 초기화
            walkingStartDate = nil
            stepCheckerButton.resetStepCount()
            
            isWalking = false
            abTestVM.stopMonitoringStepABTest()
        }
    }
    
    private func bindViewModel() {
        // WalkingVM의 걸음 수 변화 감지
        abTestVM.$abTestWalkingModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else { return }
                
                if isWalking {
                    stepABTestButton.updateButtonTtitle(text: "\(model.autoStepCount) 걸음 | 클릭시 걸음종료")
                }
            }
            .store(in: &cancellables)
    }
    
    
}

extension StepABTestView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StepABTestCell.identifier, for: indexPath) as? StepABTestCell else {
            return UITableViewCell()
        }
        
        let model = dataList[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
}

extension StepABTestView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataList[indexPath.row]
        print("선택된 항목: \(model.autoStepCount)걸음, 날짜: \(model.date)")
    }
}

//protocol WalkingABTest: AnyObject {
//    // 걷기 컨트롤 관련
//    func walkingRecordDidStartWalking(_ tableView: WalkingRecordListView)
//    func walkingRecordDidStopWalking(_ tableView: WalkingRecordListView)
//    func walkingRecordDidTapManualStep(_ tableView: WalkingRecordListView)
//    
//    // 기록 관리 관련
//    func onCellClick(_ tableView: WalkingRecordListView, didSelectRecord record: WalkingRecordModel, at index: Int)
//    func onDeleteModel(_ listView: WalkingRecordListView, didDeleteRecord record: WalkingRecordModel, at index: Int)
//    func walkingRecordListViewDidRequestExportRecords(_ listView: WalkingRecordListView, records: [WalkingRecordModel])
//}
