//
//  WalkingChartView.swift
//  FootHeart
//
//  Created by Jupond on 10/29/25.
//
import UIKit

class WalkingChartView : UIView {
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false

        // ✅ blur 배경
        view.backgroundColor = .clear
        
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
           
        return view
    }()
    
    private let durationLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let distanceLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let kcalLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let stepLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()
    
    private let kmhLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .label
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        durationLabel.text = "0초"
        distanceLabel.text = "0.0km"
        kcalLabel.text = "0 kcal"
        stepLabel.isHidden = true
        kmhLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(stackView)
        
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(kcalLabel)
        stackView.addArrangedSubview(stepLabel)
        stackView.addArrangedSubview(kmhLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        
        
        ])
    }
    
    func updateChartUI(_ model : MapWalkingModel){
        durationLabel.text = "\(model.formattedDuration)"
        distanceLabel.text = "\(model.distanceInKm)km"
        kcalLabel.text = "\(model.kcal)kcal"
        switch model.walkMode {
        case WalkMode.WALK :
            stepLabel.isHidden = false
            kmhLabel.isHidden = true
            stepLabel.text = "\(model.steps)걸음"
        case WalkMode.RUN :
            stepLabel.isHidden = true
            kmhLabel.isHidden = false
            kmhLabel.text = "\(model.averagePace)분/km"
        case WalkMode.BICYCLE :
            stepLabel.isHidden = true
            kmhLabel.isHidden = false
            kmhLabel.text = "\(model.averageSpeed)km/h"
        }
    }
}
