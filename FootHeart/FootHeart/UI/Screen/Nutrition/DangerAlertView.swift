//
//  DangerAlertView.swift
//  FootHeart
//
//  Created by Jupond on 8/26/25.
//

import UIKit

class DangerAlertView: UIView {
    
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dangerAlertLabel: UILabel = {  // UILabel로 타입 수정
        let label = UILabel()  // UILabel로 변수명 수정
        label.text = "위험 알림뷰"
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.backgroundColor = .clear  // 컨테이너가 배경을 담당하므로 투명
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        hide() // 초기에는 숨김 상태
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        hide() // 초기에는 숨김 상태
    }
    
    private func setupViews() {
        addSubview(container)
        container.addSubview(dangerAlertLabel)
      
        NSLayoutConstraint.activate([
            // 컨테이너를 DangerAlertView에 맞춤
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            // 라벨에 패딩 적용
            dangerAlertLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            dangerAlertLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            dangerAlertLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            dangerAlertLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        setupGestures()
    }
    
    func setTitle(_ title : String){
        if title.count > 0 {
            dangerAlertLabel.text = title
            show()
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dangerAlertTapped))
        container.addGestureRecognizer(tapGesture)  // 컨테이너에 제스처 추가
    }
    
    var onDangerAlertTapped: (() -> Void)?
    @objc private func dangerAlertTapped() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        onDangerAlertTapped?()
    }
    
    
    private func show(animated: Bool = true) {
        guard isHidden else { return }
        
        if animated {
            self.alpha = 0
            self.isHidden = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.alpha = 1.0
            }
        } else {
            self.alpha = 1.0
            self.isHidden = false
        }
    }
    
    /// 위험 알림을 숨김 (애니메이션 포함)
    private func hide(animated: Bool = true) {
        guard !isHidden else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
            }
        } else {
            self.alpha = 0
            self.isHidden = true
        }
    }
    
    /// 위험 알림 토글
    func toggle(animated: Bool = true) {
        if isHidden {
            show(animated: animated)
        } else {
            hide(animated: animated)
        }
    }
    
    var isVisible: Bool {
        return !isHidden && alpha > 0
    }
}
