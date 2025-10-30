//
//  DishHeaderCell.swift
//  FootHeart
//
//  Created by Jupond on 9/4/25.
//
import UIKit
class DishHeaderCell: UICollectionViewCell {
    
    static let identifier = "DishHeaderCell"
    
    var onAddButtonTapped: (() -> Void)?
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ 음식 추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // 버튼 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        }
        
        onAddButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onAddButtonTapped = nil
    }
}
