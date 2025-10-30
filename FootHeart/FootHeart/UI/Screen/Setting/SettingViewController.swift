//
//  MainController.swift
//  FootHeart
//
//  Created by Jupond on 5/20/25.
//

import UIKit
import Combine


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
