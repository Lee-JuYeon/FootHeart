//
//  TabHeaderCell.swift
//  FootHeart
//
//  Created by Jupond on 8/29/25.
//

import Foundation
import UIKit

class TabHeaderCell : UICollectionViewCell {

    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .label  // 다크모드 자동 대응
        label.font = UIFont.boldSystemFont(ofSize: 16) // 볼드(굵은 글꼴) 설정
        return label
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // underline의 색상 설정
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
       
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(underlineView)
        backgroundColor = .systemBackground  // 다크모드 자동 대응

        let height : CGFloat = 2
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor) // 추가
        ])
        
        NSLayoutConstraint.activate([
            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -height), // underline의 위치 조정
            underlineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: height) // underline의 높이 설정
        ])
    }
    
    func getLabelUnderline() -> UIView {
        return underlineView
    }
    
    func bind(model: TabModel) {
        titleLabel.text = model.title
    }
}



