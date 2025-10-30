//
//  PillHeader.swift
//  FootHeart
//
//  Created by Jupond on 8/31/25.
//

import UIKit

class PillHeader : UICollectionReusableView {
    static let identifier = "PillHeader"

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "알약 추가"
        label.layer.cornerRadius = 25
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.systemGray3.cgColor
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
        containerView.addSubview(titleLabel)
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
       
            // Title Label (텍스트)
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
  
    func configure(title: String) {
        titleLabel.text = title
    }
    
   
}
