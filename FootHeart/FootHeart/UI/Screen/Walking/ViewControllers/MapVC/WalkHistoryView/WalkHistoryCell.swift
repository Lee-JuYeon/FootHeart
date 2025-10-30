//
//  WalkHistoryCell.swift
//  FootHeart
//
//  Created by Jupond on 10/25/25.
//

import UIKit
import CoreLocation

class WalkHistoryCell: UITableViewCell {
    
    static let identifier = "WalkHistoryCell"
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let middleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(topLabel)
        contentView.addSubview(middleLabel)
        contentView.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            middleLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8),
            middleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            middleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bottomLabel.topAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: 8),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    func configure(with model: MapWalkingModel) {
        // 상단 라벨: 날짜, 시간, 거리
        topLabel.text = "🗓️ \(model.formattedDate)"
        
        middleLabel.text = "⏱️ \(model.formattedDuration)  📏 \(String(format: "%.2f", model.distanceInKm))km"
        
        // 하단 라벨: 모드별 주요 지표 + 칼로리
        switch model.walkMode {
        case .WALK:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let stepsText = numberFormatter.string(from: NSNumber(value: model.steps)) ?? "\(model.steps)"
            bottomLabel.text = "\(model.walkMode.icon) \(stepsText)걸음 | 🔥 \(String(format: "%.1f", model.kcal))kcal"
            
        case .RUN:
            bottomLabel.text = "\(model.walkMode.icon) \(model.averagePace)/km | 🔥 \(String(format: "%.1f", model.kcal))kcal"
            
        case .BICYCLE:
            bottomLabel.text = "\(model.walkMode.icon) \(String(format: "%.1f", model.averageSpeed))km/h | 🔥 \(String(format: "%.1f", model.kcal))kcal"
        }
    }
}
