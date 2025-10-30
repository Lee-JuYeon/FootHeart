//
//  WalkingRecordListView.swift
//  FootHeart
//
//  Created by Jupond on 6/18/25.
//

import UIKit
import CoreLocation

struct StepABTestModel : Hashable {
    var manualStepCount : Int
    var autoStepCount : Int
    var autoStepPath : [CLLocation]
    var date : Date
   
}

//
//class WalkingRecordListView : UIView {
//    
//    // MARK: - Properties
//    weak var delegate: WalkingABTest?
//    
//    private var walkingRecords: [WalkingRecordModel] = []
//    private var isWalking = false
//    
//    @available(iOS 13.0, *)
//    private var dataSource: UITableViewDiffableDataSource<Int, WalkingRecordModel>!
//
//    
//    private var autoStepCount = 0
//    private var manualStepCount = 0
//    
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = .systemBackground
//        tableView.separatorStyle = .singleLine
//        tableView.sectionHeaderHeight = 80
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 120
//        // 셀 및 헤더 등록
//        tableView.register(
//            WalkingRecordHeader.self,
//            forHeaderFooterViewReuseIdentifier: WalkingRecordHeader.identifier
//        )
//        tableView.register(
//            WalkingRecordCell.self,
//            forCellReuseIdentifier: WalkingRecordCell.identifier
//        )
//        return tableView
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//    
//    private func setupUI() {
//        backgroundColor = .systemBackground
//        addSubview(tableView)
//        
//        // iOS 13+ : Diffable  /  그 이하 : 전통 방식(delegate, dataSource)
//        if #available(iOS 13.0, *) {
//            configureDiffableDataSource()
//        } else {
//            tableView.dataSource = self
//        }
//        tableView.delegate = self
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Diffable (iOS 13+)
//    @available(iOS 13.0, *)
//    private func configureDiffableDataSource() {
//        dataSource = UITableViewDiffableDataSource<Int, WalkingRecordModel>(
//            tableView: tableView
//        ) { tableView, indexPath, model in
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: WalkingRecordCell.identifier,
//                for: indexPath
//            ) as! WalkingRecordCell
//            cell.configure(with: model)
//            return cell
//        }
//        applySnapshot(animating: false)
//    }
//
//    @available(iOS 13.0, *)
//    private func applySnapshot(animating: Bool = true) {
//        var snapshot = NSDiffableDataSourceSnapshot<Int, WalkingRecordModel>()
//        snapshot.appendSections([0])
//        snapshot.appendItems(walkingRecords)
//        dataSource.apply(snapshot, animatingDifferences: animating)
//    }
//
//    func addModel(_ record: WalkingRecordModel) {
//        walkingRecords.insert(record, at: 0) // 최신순 정렬
//        if #available(iOS 13.0, *) {
//            applySnapshot()
//        } else {
//            // iOS 11~12: 개별 삽입
//            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        }
//    }
//    
//    func updateList(
//        isWalking: Bool,
//        autoStepCount: Int = 0,
//        manualStepCount: Int = 0
//    ) {
//        self.isWalking = isWalking
//        self.autoStepCount = autoStepCount
//        self.manualStepCount = manualStepCount
//        
//        // 헤더 뷰 업데이트
//        if let headerView = tableView.headerView(forSection: 0) as? WalkingRecordHeader {
//            headerView.configure(
//                isWalking: isWalking,
//                autoStepCount: autoStepCount,
//                manualStepCount: manualStepCount
//            )
//        }
//    }
//    
//    func getList() -> [WalkingRecordModel] {
//        return walkingRecords
//    }
//    
//    private func deleteModel(at index: Int) {
//        guard index >= 0 && index < walkingRecords.count else { return }
//        let removedRecord =  walkingRecords.remove(at: index)
//       
//        if #available(iOS 13.0, *) {
//            applySnapshot()
//        } else {
//            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
//        }
//        delegate?.onDeleteModel(self, didDeleteRecord: removedRecord, at: index)
//    }
//    
//    
//   
//    
//}
//
//extension WalkingRecordListView: UITableViewDataSource, UITableViewDelegate {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    // header 설정
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = tableView.dequeueReusableHeaderFooterView(
//            withIdentifier: WalkingRecordHeader.identifier
//        ) as! WalkingRecordHeader
//        
//        // header binding
//        headerView.configure(
//            isWalking: isWalking,
//            autoStepCount: autoStepCount,
//            manualStepCount: manualStepCount
//        )
//        
//        // header start walking
//        headerView.onStartWalking = { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.walkingRecordDidStartWalking(self)
//        }
//        
//        // header stop walking
//        headerView.onStopWalking = { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.walkingRecordDidStopWalking(self)
//        }
//        
//        // header click waking count button
//        headerView.onManualStep = { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.walkingRecordDidTapManualStep(self)
//        }
//        
//        return headerView
//    }
//    
//    // cell 갯수
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return walkingRecords.count
//    }
//    
//    // cell binding
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: WalkingRecordCell.identifier,
//            for: indexPath
//        ) as! WalkingRecordCell
//        
//        let record = walkingRecords[indexPath.row]
//        cell.configure(with: record)
//        
//        return cell
//    }
//    
//    // cell 클릭이벤트
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let record = walkingRecords[indexPath.row]
//        delegate?.onCellClick(self, didSelectRecord: record, at: indexPath.row)
//    }
//    
//    // 스와이프 삭제 기능 (ios 11 이상)
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completionHandler in
//            // 시스템 작업 완료 알림
//            
//            self.deleteModel(at: indexPath.row)
//            completionHandler(true)
//        }
//        return UISwipeActionsConfiguration(actions: [deleteAction]) // 어떤 액션을 보여줄지 반환하는 객체
//    }
//    
//    // 스와이프 삭제 기능 (ios 10 이하)
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        // iOS 11+는 위 메서드가 대신 호출되므로 빠르게 return
//        if #available(iOS 11.0, *) { return }
//        
//        if editingStyle == .delete {
//            deleteModel(at: indexPath.row)
//        }
//    }
//    
//
//}
