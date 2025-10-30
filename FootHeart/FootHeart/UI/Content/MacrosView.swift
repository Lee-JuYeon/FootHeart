//
//  Coasdf.swift
//  FootHeart
//
//  Created by Jupond on 8/15/25.
//
import UIKit

class MacrosView : UIView {
    
    // 총 섭취한 탄수화물
    private let carboProgressBar : NutritionProgressBar = {
        let view = NutritionProgressBar()
        view.setNutrientType(.CARBOHYDRATES)
        view.setConsumeGram(50.0)
        view.updateConsumeGram(400.5)
        view.setVerticalMode(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 총 섭취한 단백질
    private let proteinProgressBar : NutritionProgressBar = {
        let view = NutritionProgressBar()
        view.setNutrientType(.PROTEIN)
        view.setConsumeGram(50.0)
        view.updateConsumeGram(40.5)
        view.setVerticalMode(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 총 섭취한 지방
    private let fatProgressBar : NutritionProgressBar = {
        let view = NutritionProgressBar()
        view.setNutrientType(.FAT)
        view.setConsumeGram(50.0)
        view.updateConsumeGram(30.0)
        view.setVerticalMode(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func updateMacrosData(carbo: Double, protein: Double, fat: Double){
        carboProgressBar.updateConsumeGram(carbo)
        proteinProgressBar.updateConsumeGram(protein)
        fatProgressBar.updateConsumeGram(fat)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // 탄단지,
    private func setupViews() {
        self.addSubview(carboProgressBar)
        self.addSubview(proteinProgressBar)
        self.addSubview(fatProgressBar)
        
        NSLayoutConstraint.activate([
            // 탄수화물 - 왼쪽에 위치
            carboProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            carboProgressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            carboProgressBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3, constant: -10), // 전체 너비의 1/3
            carboProgressBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            // 단백질 - 중앙에 위치
            proteinProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            proteinProgressBar.leadingAnchor.constraint(equalTo: carboProgressBar.trailingAnchor, constant: 5),
            proteinProgressBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3, constant: -10), // 전체 너비의 1/3
            proteinProgressBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            // 지방 - 오른쪽에 위치
            fatProgressBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            fatProgressBar.leadingAnchor.constraint(equalTo: proteinProgressBar.trailingAnchor, constant: 5),
            fatProgressBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            fatProgressBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
}
