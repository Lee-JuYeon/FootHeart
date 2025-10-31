//
//  WalkingChartView.swift
//  FootHeart
//
//  Created by Jupond on 10/29/25.
//
import UIKit

class WalkingChartView : UIView {
    
    // 블러 배경 뷰
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
        
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false

        // ✅ blur 배경
        view.backgroundColor = .clear
        
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
           
        return view
    }()
    
    private let durationLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let distanceLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let kcalLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let stepLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let kmhLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        durationLabel.text = "0초"
        distanceLabel.text = "0.0km"
        kcalLabel.text = "0 kcal"
        stepLabel.isHidden = true
        kmhLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        // 1. 블러 배경 추가 (먼저 추가)
        addSubview(blurEffectView)
        
        // 2. stackView 추가 (블러 위에)
        addSubview(stackView)
        
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(kcalLabel)
        stackView.addArrangedSubview(stepLabel)
        stackView.addArrangedSubview(kmhLabel)
        
        NSLayoutConstraint.activate([
            // 블러 배경을 stackView와 같은 크기 및 위치로
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // stackView 제약 조건
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        
        
        ])
    }
    
    // ✅ Duration 타이머 관련
    private var durationTimer: Timer?
    private var startTime: Date?
    private var pausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    
    // ✅ Duration 타이머 시작
    func startDuration() {
        stopDuration()
        
        startTime = Date()
        pausedDuration = 0
        pauseStartTime = nil
        
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDuration()
        }
        
        print("⏱️ Duration 타이머 시작")
    }
    
    // ✅ Duration 타이머 중지
    func stopDuration() {
        durationTimer?.invalidate()
        durationTimer = nil
        print("⏱️ Duration 타이머 중지")
    }
    
    // ✅ Duration 일시정지
    func pauseDuration() {
        pauseStartTime = Date()
        print("⏸️ Duration 일시정지")
    }
        
    // ✅ Duration 재개
    func resumeDuration() {
        if let pauseStart = pauseStartTime {
            pausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        print("▶️ Duration 재개")
    }
    
    // ✅ Duration 리셋
    func resetDuration() {
        startTime = nil
        pausedDuration = 0
        pauseStartTime = nil
        durationLabel.text = "0초"
        print("🔄 Duration 리셋")
    }
    
    // ✅ Duration 업데이트
    private func updateDuration() {
        guard let startTime = startTime else { return }
        
        // pause 중이면 업데이트 안 함
        if pauseStartTime != nil { return }
        
        let elapsed = Date().timeIntervalSince(startTime) - pausedDuration
        
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) % 3600 / 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            durationLabel.text = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            durationLabel.text = String(format: "%d:%02d", minutes, seconds)
        } else {
            durationLabel.text = String(format: "%d초", seconds)
        }
    }
        
    func updateChartUI(_ model : MapWalkingModel){
        // ✅ duration은 타이머로 관리하므로 제외
        distanceLabel.text = String(format: "%.2fkm", model.distanceInKm)
        kcalLabel.text = String(format: "%.1fkcal", model.kcal)
        
        switch model.walkMode {
        case WalkMode.WALK :
            stepLabel.isHidden = false
            kmhLabel.isHidden = true
            stepLabel.text = "\(model.steps)걸음"
        case WalkMode.RUN :
            stepLabel.isHidden = true
            kmhLabel.isHidden = false
            kmhLabel.text = "\(model.averagePace)분/km"
        case WalkMode.BICYCLE :
            stepLabel.isHidden = true
            kmhLabel.isHidden = false
            kmhLabel.text = String(format: "%.1fkm/h", model.averageSpeed)
        }
    }
    
    deinit {
        stopDuration()
    }
}
