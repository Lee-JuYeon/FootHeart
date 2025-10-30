//
//  ThemeWalkingHeaderView.swift
//  FootHeart
//
//  Created by Jupond on 6/12/25.
//
import UIKit

// MARK: - Collection View Header
class ThemeWalkingHeaderView: UICollectionReusableView {
    static let identifier = "ThemeWalkingHeaderView"
    
    var addThemeAction: (() -> Void)?

    private let addThemeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ 테마 추가하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        addSubview(addThemeButton)
        self.backgroundColor = .red

        NSLayoutConstraint.activate([
            addThemeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            addThemeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            addThemeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            addThemeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        addThemeButton.addTarget(self, action: #selector(addThemeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addThemeButtonTapped() {
        // 버튼 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            self.addThemeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addThemeButton.transform = .identity
            }
        }
        
        addThemeAction?()
    }
}
