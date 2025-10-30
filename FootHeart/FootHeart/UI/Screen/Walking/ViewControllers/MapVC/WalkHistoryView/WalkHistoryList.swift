//
//  WalkHistoryList.swift
//  FootHeart
//
//  Created by Jupond on 10/24/25.
//

import UIKit
import CoreLocation

class WalkHistoryList: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "📊 걷기 히스토리"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(WalkHistoryCell.self, forCellReuseIdentifier: WalkHistoryCell.identifier)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 걷기 기록이 없습니다\n오늘부터 걷기를 시작해보세요! 🚶"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    var mList: [MapWalkingModel] = [] {
        didSet {
            tableView.reloadData()
            updateEmptyState()
        }
    }
    
    // 셀 선택 콜백
    var onSelectHistory: ((MapWalkingModel) -> Void)?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private weak var getSheetView: UIView?
    func setSheetView(_ sheetView: UIView) {
        self.getSheetView = sheetView
        setupUI()  // 🔥 이게 빠져있었음!
    }
    
    private func setupUI() {
        guard let bottomSheetContentView = getSheetView else {
            print("❌ sheetView가 설정되지 않았습니다.")
            return
        }
                
        tableView.dataSource = self
        tableView.delegate = self
        
        bottomSheetContentView.addSubview(titleLabel)
        bottomSheetContentView.addSubview(emptyStateLabel)
        bottomSheetContentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: bottomSheetContentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: bottomSheetContentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: bottomSheetContentView.trailingAnchor, constant: -20),
            
            // Empty State Label
            emptyStateLabel.centerXAnchor.constraint(equalTo: bottomSheetContentView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: bottomSheetContentView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: bottomSheetContentView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: bottomSheetContentView.trailingAnchor, constant: -40),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: bottomSheetContentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomSheetContentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomSheetContentView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = mList.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension WalkHistoryList: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WalkHistoryCell.identifier,
            for: indexPath
        ) as? WalkHistoryCell else {
            return UITableViewCell()
        }
        
        let model = mList[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = mList[indexPath.row]
        onSelectHistory?(model)
    }
}
