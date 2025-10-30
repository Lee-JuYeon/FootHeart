//
//  Untitled.swift
//  FootHeart
//
//  Created by Jupond on 10/19/25.
//
import UIKit

class TimerLabel : UILabel {
        
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 현재 걸음 수를 저장하는 프로퍼티
    var timeCount: Int = 0 {
        didSet {
            text = "⏱️ \(timeCount)"
        }
    }
    
    private func setupUI() {
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textAlignment = .center
        textColor = .label
        backgroundColor = .systemTeal
        clipsToBounds = true
        text = "⏱️ 00:00:00"
    }
      
    // 실제 크기가 결정된 후
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2  // 높이의 절반 = 완전한 둥근 모양, 고정값(25) 대신 동적으로 계산
    }
    
    // 텍스트 패딩 적용
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        super.drawText(in: rect.inset(by: insets))
    }
    
    // intrinsicContentSize도 패딩만큼 증가
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 32, height: size.height + 16)
    }
       
   
}
