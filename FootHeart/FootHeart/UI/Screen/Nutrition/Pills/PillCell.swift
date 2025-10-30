//
//  PillCell.swift
//  FootHeart
//
//  Created by Jupond on 8/31/25.
//

import UIKit
class PillCell: UICollectionViewCell {
    static let identifier = "PillCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pillContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pillUpperPart: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let pillUnderPart: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium) // 글자 크기 줄임
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // 알약 부분을 별도 컨테이너에 넣음
        pillContainerView.addSubview(pillUpperPart)
        pillContainerView.addSubview(pillUnderPart)
        
        containerView.addSubview(pillContainerView)
        containerView.addSubview(nameLabel)
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            // Pill Container View (알약 부분)
            pillContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pillContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pillContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pillContainerView.heightAnchor.constraint(equalToConstant: 60), // 고정 높이
            
            // Pill Upper Part
            pillUpperPart.topAnchor.constraint(equalTo: pillContainerView.topAnchor),
            pillUpperPart.leadingAnchor.constraint(equalTo: pillContainerView.leadingAnchor),
            pillUpperPart.trailingAnchor.constraint(equalTo: pillContainerView.trailingAnchor),
            pillUpperPart.heightAnchor.constraint(equalTo: pillContainerView.heightAnchor, multiplier: 0.5),
            
            // Pill Under Part
            pillUnderPart.topAnchor.constraint(equalTo: pillUpperPart.bottomAnchor),
            pillUnderPart.leadingAnchor.constraint(equalTo: pillContainerView.leadingAnchor),
            pillUnderPart.trailingAnchor.constraint(equalTo: pillContainerView.trailingAnchor),
            pillUnderPart.bottomAnchor.constraint(equalTo: pillContainerView.bottomAnchor),
            
            // Name Label (남은 공간 차지)
            nameLabel.topAnchor.constraint(equalTo: pillContainerView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2)
        ])
    }
    
    func configure(topColour: UIColor, bottomColour: UIColor, title: String) {
        pillUpperPart.backgroundColor = topColour
        pillUnderPart.backgroundColor = bottomColour
        nameLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pillUpperPart.backgroundColor = .clear
        pillUnderPart.backgroundColor = .clear
        nameLabel.text = nil
    }
}
