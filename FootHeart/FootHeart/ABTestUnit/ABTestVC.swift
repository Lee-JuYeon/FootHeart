//
//  ABTestVC.swift
//  FootHeart
//
//  Created by Jupond on 10/16/25.
//


import UIKit
import CoreLocation
import MapKit
import Combine

class ABTestVC: UIViewController {
    
    private let stepABTestView : StepABTestView = {
        let view = StepABTestView(abTestVM: ABTestVM())
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
        
        setupViews()
        
    }
    
    private func setupViews(){
        view.backgroundColor = .systemBackground
        view.addSubview(stepABTestView)
        
        
        NSLayoutConstraint.activate([
   
            stepABTestView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepABTestView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepABTestView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepABTestView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)  // ✅ 추가!

        ])
    }
    
   
}

