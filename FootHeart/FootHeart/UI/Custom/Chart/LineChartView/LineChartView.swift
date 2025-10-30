//
//  LineChartView.swift
//  FootHeart
//
//  Created by Jupond on 8/24/25.
//
import UIKit

class LineChartView: UIView {
    
    // MARK: - Properties
    var dataPoints: [LineChartData] = [] {
        didSet {
            updateChart()  // 데이터가 변경되면 차트 업데이트
        }
    }
    
    // 차트 스타일 설정
    var lineColor: UIColor = .systemBlue    // 연결선 색상
    var pointColor: UIColor = .black    // 데이터 포인트 색상
    var gridColor: UIColor = .clear   // 배경 그리드 색상
    var textColor: UIColor = .label         // 텍스트 색상
    
    // UI 구성 요소들 - lazy로 선언해서 초기화 지연
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(LineChartPointCell.self, forCellWithReuseIdentifier: "LineChartPointCell")
        return cv
    }()
    private let backgroundGridView = UIView()        // 배경 그리드를 그릴 뷰
    private let lineView = LineChartLineView()          // 포인트들을 연결하는 선을 그릴 뷰
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setupViews()
    }
    
    private func setUI(){
        // CollectionView 레이아웃 설정
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal        // 가로 스크롤
        layout.minimumInteritemSpacing = 0         // 셀 간 간격 없음
        layout.minimumLineSpacing = 0              // 줄 간격 없음
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        
        // 1. 배경 그리드 뷰 추가 (맨 아래 레이어)
        backgroundGridView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGridView)
        
        // 2. 라인 뷰 추가 (중간 레이어)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        
        // 3. 컬렉션뷰 설정 (맨 위 레이어)
        addSubview(collectionView)
        
        // 제약조건 설정 - 모든 뷰를 같은 위치에 겹쳐서 배치
        NSLayoutConstraint.activate([
            // 배경 그리드 (여백: 상40, 좌60, 우40, 하60)
            backgroundGridView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            backgroundGridView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            backgroundGridView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            backgroundGridView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            
            // 라인 뷰는 그리드와 같은 크기
            lineView.topAnchor.constraint(equalTo: backgroundGridView.topAnchor),
            lineView.leadingAnchor.constraint(equalTo: backgroundGridView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: backgroundGridView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: backgroundGridView.bottomAnchor),
            
            // 컬렉션뷰도 그리드와 같은 크기
            collectionView.topAnchor.constraint(equalTo: backgroundGridView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: backgroundGridView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: backgroundGridView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: backgroundGridView.bottomAnchor)
        ])
        
        setupBackgroundGrid()
    }
    
    private func setupBackgroundGrid() {
        let gridLayer = CALayer()
        backgroundGridView.layer.addSublayer(gridLayer)
        
        // 그리드 그리기는 layoutSubviews에서 처리
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawBackgroundGrid()
        updateChart()
    }
    
    private func drawBackgroundGrid() {
        backgroundGridView.layer.sublayers?.removeAll()
        
        let gridLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        let rect = backgroundGridView.bounds
        
        // 세로 그리드 라인 (5개)
        for i in 0...4 {
            let x = rect.width * CGFloat(i) / 4
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // 가로 그리드 라인 (5개)
        for i in 0...4 {
            let y = rect.height * CGFloat(i) / 4
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        }
        
        gridLayer.path = path.cgPath
        gridLayer.strokeColor = gridColor.cgColor
        gridLayer.lineWidth = 0.5
        
        backgroundGridView.layer.addSublayer(gridLayer)
    }
    
    private func updateChart() {
        guard !dataPoints.isEmpty else { return }
        
        // 라인 업데이트
        lineView.dataPoints = dataPoints
        lineView.lineColor = lineColor
        
        // 컬렉션뷰 리로드
        collectionView.reloadData()
    }
    
    // MARK: - Public Methods
    func setDataPoints(_ points: [LineChartData], animated: Bool = true) {
        dataPoints = points
        
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.updateChart()
            }
        }
    }
}

extension LineChartView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 데이터 포인트 개수만큼 셀 생성
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineChartPointCell", for: indexPath) as! LineChartPointCell
        
        let dataPoint = dataPoints[indexPath.item]
        let (_, _, minY, maxY) = calculateDataRange()  // 데이터 범위 계산
        
        // Y 위치 계산 (0-1 범위로 정규화)
        let normalizedY = (dataPoint.y - minY) / (maxY - minY)
        
        cell.configure(
            value: dataPoint.y,           // 실제 데이터 값
            normalizedY: 1.0 - normalizedY,  // Y축 뒤집기 (상단이 높은 값)
            label: dataPoint.label,       // 라벨 텍스트
            color: pointColor            // 포인트 색상
        )
        return cell
    }
    
    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 전체 너비를 데이터 개수로 나누기
        let width = collectionView.bounds.width / CGFloat(dataPoints.count)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    private func calculateDataRange() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let xValues = dataPoints.map { $0.x }
        let yValues = dataPoints.map { $0.y }
        
        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 1
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        
        let yRange = maxY - minY
        let yPadding = yRange * 0.1
        
        return (minX, maxX, minY - yPadding, maxY + yPadding)
    }
}
