//
//  LineChartPointCell.swift
//  FootHeart
//
//  Created by Jupond on 8/24/25.
//
import UIKit

// MARK: - Chart Point Cell
class LineChartPointCell: UICollectionViewCell {
    
    private let pointView = UIView()      // 실제 데이터 포인트 (원)
    private let valueLabel = UILabel()    // 포인트 위의 값 표시
    private let bottomLabel = UILabel()   // 포인트 아래의 라벨 (예: "월")
     
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // 포인트 뷰 설정
        pointView.translatesAutoresizingMaskIntoConstraints = false
        pointView.layer.cornerRadius = 4
        contentView.addSubview(pointView)
        
        // 값 라벨 (포인트 위)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .label
        contentView.addSubview(valueLabel)
        
        // 하단 라벨
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        bottomLabel.textAlignment = .center
        bottomLabel.textColor = .secondaryLabel
        contentView.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate([
            // 포인트 뷰는 normalizedY에 따라 위치 조정 (제약조건은 configure에서 설정)
            pointView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pointView.widthAnchor.constraint(equalToConstant: 8),
            pointView.heightAnchor.constraint(equalToConstant: 8),
            
            // 값 라벨
            valueLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: pointView.topAnchor, constant: -5),
            
            // 하단 라벨
            bottomLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private var pointYConstraint: NSLayoutConstraint?
    
    func configure(value: CGFloat, normalizedY: CGFloat, label: String?, color: UIColor) {
        pointView.backgroundColor = color
        valueLabel.text = String(format: "%.0f", value)  // 소수점 없이 정수로 표시
        bottomLabel.text = label
        
        // 기존 Y 위치 제약조건 제거
        if let constraint = pointYConstraint {
            constraint.isActive = false
        }
        
        // 새 Y 위치 설정, Y 위치를 normalizedY 값에 따라 동적으로 설정
        pointYConstraint = pointView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: contentView.bounds.height * normalizedY - 4 // -4는 포인트 반지름만큼 조정
        )
        pointYConstraint?.isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pointYConstraint?.isActive = false
        pointYConstraint = nil
    }
}

