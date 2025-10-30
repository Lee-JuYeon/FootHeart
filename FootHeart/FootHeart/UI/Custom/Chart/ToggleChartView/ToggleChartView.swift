//
//  CustomProgressBar.swift
//  FootHeart
//
//  Created by Jupond on 8/15/25.
//
import UIKit

class ToggleChartView : UIView {
    
    var toggleOptions: [String] = [] {
        didSet {
            toggleListView.reloadData()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            toggleListView.reloadData()
            onToggleSelected?(selectedIndex)
        }
    }
    
    // 외부 클로저 - 셀 클릭 이벤트
     var onToggleSelected: ((Int) -> Void)?
    
    private let toggleListView : UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.register(ToggleListCell.self, forCellReuseIdentifier: "ToggleListCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lineChartView : LineChartView = {
        let view = LineChartView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // 차트 샘플 데이터 설정
    private func setupChartSampleData() {
        // 일주일간의 칼로리 섭취량 샘플 데이터
        let sampleData = [
            LineChartData(x: 1, y: 1800, label: "월"),
            LineChartData(x: 2, y: 2100, label: "화"),
            LineChartData(x: 3, y: 1950, label: "수"),
            LineChartData(x: 4, y: 2200, label: "목"),
            LineChartData(x: 5, y: 1850, label: "금"),
            LineChartData(x: 6, y: 2000, label: "토"),
            LineChartData(x: 7, y: 1900, label: "일")
        ]
        
       
        
        // 데이터 설정 (애니메이션과 함께)
        lineChartView.setDataPoints(sampleData, animated: true)
    }
    
    
    private func setupViews(){
        // 둥근 테두리 배경 설정
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        
        toggleListView.dataSource = self
        toggleListView.delegate = self
        
        addSubview(toggleListView)
        addSubview(lineChartView)
        
        NSLayoutConstraint.activate([
            // ToggleListView - 왼쪽
            toggleListView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            toggleListView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            toggleListView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            toggleListView.widthAnchor.constraint(equalToConstant: 100),
            
            // LineChartView - 오른쪽
            lineChartView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            lineChartView.leadingAnchor.constraint(equalTo: toggleListView.trailingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            lineChartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        // 초기 데이터 설정
        setupInitialData()
    }
    
    
    private func setupInitialData() {
        toggleOptions = ["혈압", "체중", "혈당", "부종"]
        selectedIndex = 0
        
        setupChartSampleData()
    }
    
    func updateChartData(for index: Int, data: [LineChartData]) {
        lineChartView.setDataPoints(data, animated: true)
    }
    
    func setToggleOptions(_ options: [String]) {
        toggleOptions = options
        if !options.isEmpty {
            selectedIndex = 0
        }
    }
}

extension ToggleChartView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toggleOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleListCell", for: indexPath) as! ToggleListCell
        
        let option = toggleOptions[indexPath.row]
        let isSelected = indexPath.row == selectedIndex
        
        cell.configure(text: option, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // 이미 선택된 셀을 다시 클릭해도 상태 변경 없음
        if indexPath.row == selectedIndex {
            return
        }
        
        // 새로운 셀 선택
        selectedIndex = indexPath.row
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
}
