//
//  NutritionDetectorView.swift
//  FootHeart
//
//  Created by Jupond on 8/15/25.
//
import UIKit

class NutritionDetectorView : UIView {
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("음식 추가", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews(){
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            button.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0),
            button.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0),
        ])
        
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)

    }
    
    @objc private func buttonClick(){
        print("음식 추가 버튼 클릭")
               
//        // 햅틱 피드백
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        impactGenerator.impactOccurred()
//        
//        // 버튼 애니메이션
//        animateButton(leftButton)
//        
//        // 음식 추가 액션시트 표시
//        showFoodAddActionSheet()
        
        // 내가 요리한 경우
        // 남이 요리한 경우 (받거나 사거나)
        // 밀키트를 산 경우  -> 영양성분표 찍기
        // 밀키트에 내가 추가로 조리한 경우
        
    }
}
