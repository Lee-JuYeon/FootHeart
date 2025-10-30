//
//  MealKitViewController.swift
//  FootHeart
//
//  Created by Jupond on 8/30/25.
//

import UIKit

class MealKitViewController : UIViewController {
    
    private let label: UILabel = {  // UILabel로 타입 수정
        let label = UILabel()  // UILabel로 변수명 수정
        label.text = "밀키트 구매와 추천 리스트뷰"
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.backgroundColor = .green  // 컨테이너가 배경을 담당하므로 투명
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])

    }
}
