//
//  WalkRecordButton.swift
//  FootHeart
//
//  Created by Jupond on 10/26/25.
//

import UIKit

protocol WalkRecordDelegate : AnyObject {
    func onChangeRecordState(_ mode : WalkRecordState)
}

class WalkRecordButton: UIView {
    
    weak var eventDelegate : WalkRecordDelegate?
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
    
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 45
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        let image = UIImage(systemName: "play.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        let image = UIImage(systemName: "stop.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        
        return button
    }()
        
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private var stackViewWidthConstraint: NSLayoutConstraint! // backgroundWidthConstraint → stackViewWidthConstraint

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let visibleCount = [startButton, stopButton, pauseButton].filter { !$0.isHidden }.count
        if visibleCount == 1 {
            return CGSize(width: 90, height: 90)  // ✅ 94 → 90
        } else {
            let width = CGFloat(visibleCount) * 90 + CGFloat(visibleCount - 1) * 16
            return CGSize(width: width, height: 90)  // ✅ 94 → 90
        }
    }
    
    private func setupUI() {
        self.isUserInteractionEnabled = true
        addSubview(stackView)
        
        // ✅ 초기 상태: stopButton, pauseButton 숨김
        stopButton.isHidden = true
        pauseButton.isHidden = true
        
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(stopButton)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 90),
            
            startButton.widthAnchor.constraint(equalToConstant: 90),
            stopButton.widthAnchor.constraint(equalToConstant: 90),
            pauseButton.widthAnchor.constraint(equalToConstant: 90),
        ])
        
        startButton.addTarget(self, action: #selector(onStartTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(onStopTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(onPauseTapped), for: .touchUpInside)
    }
    
    private var walkRecordState: WalkRecordState = .STOP {
        didSet {
            updateButtonState()
        }
    }
    
    private func updateButtonState() {
        switch walkRecordState {
        case .STOP:
            startButton.isHidden = false
            stopButton.isHidden = true
            pauseButton.isHidden = true
            stackView.layer.cornerRadius = 45
            
        case .START:
            startButton.isHidden = true
            stopButton.isHidden = false
            pauseButton.isHidden = false
            stackView.layer.cornerRadius = 45
            
        case .PAUSE:
            startButton.isHidden = false
            stopButton.isHidden = false
            pauseButton.isHidden = true
            stackView.layer.cornerRadius = 45
        case .RESUME:
            walkRecordState = .START
            return
        }
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }
   
    // ✅ Start 버튼 탭: STOP→START 또는 PAUSE→RESUME
    @objc private func onStartTapped() {
        if walkRecordState == .STOP {
            walkRecordState = .START
            eventDelegate?.onChangeRecordState(.START)
        } else if walkRecordState == .PAUSE {
            walkRecordState = .START  // UI는 START 상태로
            eventDelegate?.onChangeRecordState(.RESUME)  // 델리게이트에는 RESUME 전달
        }
    }

    // ✅ Stop 버튼 탭: 종료
    @objc private func onStopTapped() {
        walkRecordState = .STOP
        eventDelegate?.onChangeRecordState(.STOP)
    }

    // ✅ Pause 버튼 탭: 일시정지
    @objc private func onPauseTapped() {
        walkRecordState = .PAUSE
        eventDelegate?.onChangeRecordState(.PAUSE)
    }
}
