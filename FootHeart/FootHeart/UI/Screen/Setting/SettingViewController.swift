//
//  MainController.swift
//  FootHeart
//
//  Created by Jupond on 5/20/25.
//

import UIKit
import Combine

/*
 settingviewcontroller의 ui를 전체적으로 바꿀건데,
 1. 약관 리스트 (서비스 이용약관, 개인정보처리방침, 민감(건강)정보처리에 대한 동의, 위치기반 서비스 이용약관)
 2. bmi ui list (bmi model을 기반으로 bmi를 입력하는 ui들을 만들꺼야). 구성해봐
 3. 기타 (버전 정보, 오픈소스 라이센스)
 */

class SettingViewController: UITabBarController {
    
//    private let walkingChipButton: ChipView = {
//        let view = ChipView(text: "🦶🏻 settingVC", onTap: {
//            
//        })
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()

    
    private let eatKcalLabel : UILabel = {
        let view = UILabel()
        view.text = "🍴 12,000Kcal"
        view.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.textColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exerciseKcalLabel : UILabel = {
        let view = UILabel()
        view.text = "🔥 82,132Kcal"
        view.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.textColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
      
    }
   
    
    private func setUI(){
        view.backgroundColor = .systemBackground
//        view.addSubview(walkingChipButton)
//        
//        NSLayoutConstraint.activate([
//            walkingChipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            walkingChipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//        ])
    }
 
}
