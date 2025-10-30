//
//  WalkingRecordHeader.swift
//  FootHeart
//
//  Created by Jupond on 6/18/25.
//
import UIKit

class StepABTestButton : UIButton {
    
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setTitle("걷기 시작", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        backgroundColor = .systemBlue
        layer.cornerRadius = 12
        clipsToBounds = true
        
        // 패딩 적용
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
    
    private func setupAction() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
     
    }

    private var isWalking : Bool = false
    @objc private func buttonTapped() {
        switch isWalking {
        case false :  // ✅ 수정: 걷기 시작할 때
            setTitle("걷기 끝", for: .normal)
            isWalking = true
            onWalkingStart?()
            break;
        case true :  // ✅ 수정: 걷기 종료할 때
            setTitle("걷기 시작", for: .normal)
            isWalking = false
            onWalkingStop?()
            break;
        }
    }
    
    
    var onWalkingStart: (() -> Void)?
    var onWalkingStop: (() -> Void)?
    
    func updateButtonTtitle(text : String){
        setTitle(text, for: .normal)
    }
}

//
//class WalkingRecordHeader: UITableViewHeaderFooterView {
//    
//    static let identifier = "WalkingRecordHeader"
//    
//    // MARK: - UI Components
//    private let startButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("걷기 시작", for: .normal)
//        button.backgroundColor = .systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        button.layer.cornerRadius = 12
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let stopButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("걷기 종료", for: .normal)
//        button.backgroundColor = .systemRed
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let stepCountLabel: UILabel = {
//        let label = UILabel()
//        label.text = "자동: 0걸음\n수동: 0걸음"
//        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .label
//        label.textAlignment = .center
//        label.numberOfLines = 2
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let manualStepButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("걷기 카운트", for: .normal)
//        button.backgroundColor = .systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let walkingControlsStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 12
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
//    // MARK: - Callbacks
//    var onStartWalking: (() -> Void)?
//    var onStopWalking: (() -> Void)?
//    var onManualStep: (() -> Void)?
//    
//    // MARK: - Initialization
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        setupUI()
//        setupActions()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Setup Methods
//    private func setupUI() {
//        backgroundView = UIView()
//        backgroundView?.backgroundColor = .systemBackground
//        
//        contentView.addSubview(startButton)
//        contentView.addSubview(walkingControlsStackView)
//        
//        walkingControlsStackView.addArrangedSubview(stopButton)
//        walkingControlsStackView.addArrangedSubview(stepCountLabel)
//        walkingControlsStackView.addArrangedSubview(manualStepButton)
//        
//        NSLayoutConstraint.activate([
//            // 시작 버튼
//            startButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            startButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            startButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            // 걷기 컨트롤 스택뷰
//            walkingControlsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            walkingControlsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            walkingControlsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            walkingControlsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            
//            // 버튼 높이
//            stopButton.heightAnchor.constraint(equalToConstant: 60),
//            manualStepButton.heightAnchor.constraint(equalToConstant: 60)
//        ])
//    }
//    
//    private func setupActions() {
//        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
//        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
//        manualStepButton.addTarget(self, action: #selector(manualStepButtonTapped), for: .touchUpInside)
//    }
//    
//    // MARK: - Action Methods
//    @objc private func startButtonTapped() {
//        addButtonAnimation(button: startButton)
//        onStartWalking?()
//    }
//    
//    @objc private func stopButtonTapped() {
//        addButtonAnimation(button: stopButton)
//        onStopWalking?()
//    }
//    
//    @objc private func manualStepButtonTapped() {
//        addButtonAnimation(button: manualStepButton)
//        onManualStep?()
//    }
//    
//    private func addButtonAnimation(button: UIButton) {
//        UIView.animate(withDuration: 0.1, animations: {
//            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }) { _ in
//            UIView.animate(withDuration: 0.1) {
//                button.transform = .identity
//            }
//        }
//    }
//    
//    // MARK: - Configuration
//    func configure(isWalking: Bool, autoStepCount: Int, manualStepCount: Int) {
//        if isWalking {
//            startButton.isHidden = true
//            walkingControlsStackView.isHidden = false
//            stepCountLabel.text = "🤖 자동: \(autoStepCount)걸음\n👆 수동: \(manualStepCount)걸음"
//        } else {
//            startButton.isHidden = false
//            walkingControlsStackView.isHidden = true
//        }
//    }
//}
