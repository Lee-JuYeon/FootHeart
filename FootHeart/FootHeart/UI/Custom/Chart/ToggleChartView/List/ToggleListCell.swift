//
//  ToggleListCell.swift
//  FootHeart
//
//  Created by Jupond on 8/24/25.
//
import UIKit

class ToggleListCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(text: String, isSelected: Bool) {
        titleLabel.text = text
        
        if isSelected {
            // 선택된 상태 - 하늘색 칩 모양
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            containerView.layer.cornerRadius = 16
            containerView.layer.borderWidth = 0
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        } else {
            // 선택되지 않은 상태
            containerView.backgroundColor = .clear
            containerView.layer.cornerRadius = 16
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            titleLabel.textColor = .label
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        // 애니메이션 효과
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        titleLabel.textColor = .label
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
}
