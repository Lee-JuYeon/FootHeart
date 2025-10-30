//
//  WalkingRecordCell.swift
//  FootHeart
//
//  Created by Jupond on 6/18/25.
//

import UIKit

class StepABTestCell: UITableViewCell {
    
    static let identifier = "StepABTestCell"
    
    private let stepCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(stepCountLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            stepCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stepCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: stepCountLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    func configure(with model: StepABTestModel) {
        stepCountLabel.text = "수동 \(model.manualStepCount) | 자동 \(model.autoStepCount)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: model.date)
        
    }
}


//class WalkingRecordCell: UITableViewCell {
//    
//    static let identifier = "WalkingRecordCell"
//    
//    // MARK: - UI Components
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .secondarySystemBackground
//        view.layer.cornerRadius = 12
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let timeLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let durationLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .systemBlue
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let stepInfoLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        label.textColor = .label
//        label.numberOfLines = 2
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let distanceLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .systemGreen
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let routeInfoLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        label.textColor = .tertiaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // MARK: - Initialization
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Setup Methods
//    private func setupUI() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        
//        contentView.addSubview(containerView)
//        
//        containerView.addSubview(dateLabel)
//        containerView.addSubview(timeLabel)
//        containerView.addSubview(durationLabel)
//        containerView.addSubview(stepInfoLabel)
//        containerView.addSubview(distanceLabel)
//        containerView.addSubview(routeInfoLabel)
//        
//        NSLayoutConstraint.activate([
//            // 컨테이너 뷰
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            
//            // 날짜 라벨
//            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            
//            // 시간 라벨
//            timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
//            timeLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
//            
//            // 지속시간 라벨
//            durationLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
//            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // 걸음수 정보 라벨
//            stepInfoLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
//            stepInfoLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
//            stepInfoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            // 거리 라벨
//            distanceLabel.topAnchor.constraint(equalTo: stepInfoLabel.bottomAnchor, constant: 4),
//            distanceLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
//            
//            // 루트 정보 라벨
//            routeInfoLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 4),
//            routeInfoLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
//            routeInfoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
//        ])
//    }
//    
//    // MARK: - Configuration
//    func configure(with record: WalkingRecordModel) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
//        
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateStyle = .none
//        timeFormatter.timeStyle = .short
//        
//        let durationFormatter = DateComponentsFormatter()
//        durationFormatter.allowedUnits = [.hour, .minute, .second]
//        durationFormatter.unitsStyle = .abbreviated
//        
//        dateLabel.text = dateFormatter.string(from: record.startDate)
//        timeLabel.text = "\(timeFormatter.string(from: record.startDate)) - \(timeFormatter.string(from: record.endDate))"
//        durationLabel.text = "⏱️ \(durationFormatter.string(from: record.duration) ?? "")"
//        stepInfoLabel.text = "🤖 자동: \(record.autoStepCount)걸음\n👆 수동: \(record.manualStepCount)걸음"
//        
//        // 거리 표시 (미터/킬로미터)
//        if record.distance >= 1000 {
//            distanceLabel.text = "📏 \(String(format: "%.2f", record.distance / 1000))km"
//        } else {
//            distanceLabel.text = "📏 \(String(format: "%.0f", record.distance))m"
//        }
//        
//        routeInfoLabel.text = "🗺️ 경로 포인트: \(record.route.count)개"
//    }
//    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        
//        UIView.animate(withDuration: 0.1) {
//            self.containerView.backgroundColor = highlighted ? .tertiarySystemBackground : .secondarySystemBackground
//            self.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
//        }
//    }
//}
