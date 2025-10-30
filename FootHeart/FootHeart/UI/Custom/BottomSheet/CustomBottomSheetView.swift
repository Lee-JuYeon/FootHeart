//
//  BottomSheetView.swift
//  FootHeart
//
//  Created by Jupond on 8/26/25.
//

import UIKit

class CustomBottomSheetView: UIViewController {
    
    // 외부에서 컨텐츠를 설정할 수 있는 클로저
    var setContentView: ((UIView) -> Void)?
    
    private let backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground // 블러 위에 실제 컨텐츠 배경
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
      
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚠️ 위험 알림"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
      
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
        현재 위험 상황이 감지되었습니다.
        
        • 주변 환경을 확인하세요
        • 안전한 장소로 이동하세요
        • 필요시 응급상황에 대비하세요
        """
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupGestures()
        
        // 외부 클로저 호출 - contentView를 전달
        setContentView?(contentView)
    }
       
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(backgroundView) // 블러 배경을 먼저 추가
        view.addSubview(contentView) // 컨텐츠를 블러 배경 위에 추가
     
    }
    
    // 애니메이션을 위한 제약조건
    private var contentViewBottomConstraint: NSLayoutConstraint!

       
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 블러 배경 (전체 화면)
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 컨텐츠 뷰 (바텀시트)
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
            
            
        ])
        
        // 애니메이션을 위한 bottom 제약조건 (초기에는 화면 밖에 위치)
        contentViewBottomConstraint = contentView.topAnchor.constraint(equalTo: view.bottomAnchor)
        contentViewBottomConstraint.isActive = true
    }
    
    private func setupGestures() {
        // 블러 배경 클릭 시 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        

    }
  
    @objc private func backgroundTapped() {
        animateOut()
    }
    
    // 나타날 때 애니메이션
    private func animateIn() {
        // 초기 상태: 배경 투명, 컨텐츠 화면 밖
        backgroundView.alpha = 0
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2) {
            // 배경 빠르게 나타남
            self.backgroundView.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            // 컨텐츠 아래에서 위로 슬라이드
            self.contentViewBottomConstraint.isActive = false
            self.contentViewBottomConstraint = self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.contentViewBottomConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    // 사라질 때 애니메이션
    private func animateOut() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            // 컨텐츠 아래로 슬라이드
            self.contentViewBottomConstraint.isActive = false
            self.contentViewBottomConstraint = self.contentView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
            self.contentViewBottomConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1) {
            // 배경 서서히 사라짐
            self.backgroundView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc func sheetDismiss() {
        animateOut()
        dismiss(animated: true)
    }
}


