//
//  WalkModeView.swift
//  FootHeart
//
//  Created by Jupond on 10/27/25.
//

import UIKit

protocol WalkModeViewDelegate : AnyObject {
    func onChangeWalkMode(_ mode : WalkMode)
}

class WalkModeView: UIView {
    
    weak var eventDelegate : WalkModeViewDelegate?
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical  // ✅ 위로 펼쳐지도록 vertical
        view.spacing = 8
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let choiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
//        let image = UIImage(systemName: "chevron.up", withConfiguration: config)
//        button.setImage(image, for: .normal)
        button.setTitle("Mode", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        return button
    }()
    
    private let walkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "figure.walk", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let runButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "figure.walk", withConfiguration: config)  // ✅ 수정
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
        
    private let bicycleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "bicycle", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private var isExpanded = false
    private var currentMode: WalkMode? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 60, height: isExpanded ? 248 : 60)  // 60 * 4 + 8 * 3
    }
    
    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(bicycleButton)
        stackView.addArrangedSubview(runButton)
        stackView.addArrangedSubview(walkButton)
        stackView.addArrangedSubview(choiceButton)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            choiceButton.heightAnchor.constraint(equalToConstant: 60),
            walkButton.heightAnchor.constraint(equalToConstant: 60),
            runButton.heightAnchor.constraint(equalToConstant: 60),
            bicycleButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        choiceButton.addTarget(self, action: #selector(onChoiceTapped), for: .touchUpInside)
        walkButton.addTarget(self, action: #selector(onWalkTapped), for: .touchUpInside)
        runButton.addTarget(self, action: #selector(onRunTapped), for: .touchUpInside)
        bicycleButton.addTarget(self, action: #selector(onBicycleTapped), for: .touchUpInside)
    }
    
    @objc private func onChoiceTapped() {
        toggleExpand()
    }
    

    @objc private func onWalkTapped() {
        selectMode(.WALK, icon: "figure.walk")
        eventDelegate?.onChangeWalkMode(WalkMode.WALK)
    }
    
    @objc private func onRunTapped() {
        selectMode(.RUN, icon: "figure.walk")
        eventDelegate?.onChangeWalkMode(WalkMode.RUN)
    }
    
    @objc private func onBicycleTapped() {
        selectMode(.BICYCLE, icon: "bicycle")
        eventDelegate?.onChangeWalkMode(WalkMode.BICYCLE)
    }
    
    private func toggleExpand() {
        isExpanded.toggle()
        
        // ✅ 확장 시 무조건 3개 다 표시
        self.walkButton.isHidden = !isExpanded
        self.runButton.isHidden = !isExpanded
        self.bicycleButton.isHidden = !isExpanded
        
        self.invalidateIntrinsicContentSize()
        self.superview?.layoutIfNeeded()
    }
    
    private func selectMode(_ mode: WalkMode, icon: String) {
        currentMode = mode
           
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: icon, withConfiguration: config)
        choiceButton.setImage(image, for: .normal)
        choiceButton.setTitle(nil, for: .normal)
        choiceButton.semanticContentAttribute = .unspecified
        choiceButton.imageEdgeInsets = .zero
        
        isExpanded = false
        self.walkButton.isHidden = true
        self.runButton.isHidden = true
        self.bicycleButton.isHidden = true
        
        self.invalidateIntrinsicContentSize()
        self.superview?.layoutIfNeeded()
    }
}
