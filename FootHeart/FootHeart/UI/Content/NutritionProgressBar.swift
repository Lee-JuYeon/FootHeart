//
//  NutritionProgressBar.swift
//  FootHeart
//
//  Created by Jupond on 8/15/25.
//
import UIKit

class NutritionProgressBar : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // 수평용 UIProgressView
    private let progressView : UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.trackTintColor = UIColor.systemGray5
        view.progressTintColor = UIColor.systemYellow
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.setProgress(0, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 수직용 커스텀 ProgressView
    private let customVerticalProgressView = VerticalProgressBar()
    
    private let titleView : UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        view.textColor = .label
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gramLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        // 텍스트 외곽선 효과
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.8
        label.layer.shadowRadius = 1
        return label
    }()
    
    private let progressContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isVertical: Bool = false
    func setVerticalMode(_ vertical: Bool) {
        isVertical = vertical
        setupViews()
    }
      
    private func setupViews(){
        backgroundColor = .clear
        
        // 기존 제약조건 모두 제거
        self.removeConstraints(self.constraints)
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        if isVertical {
            setupVerticalLayout()
        } else {
            setupHorizontalLayout()
        }
        
        updateUI()
    }
    
    private func setupVerticalLayout(){
        addSubview(titleView)
        addSubview(customVerticalProgressView)
        addSubview(gramLabel)
        
        customVerticalProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 커스텀 수직 프로그레스바를 상단에서 대부분 공간 차지
            customVerticalProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 25), // gramLabel 공간 확보
            customVerticalProgressView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            customVerticalProgressView.widthAnchor.constraint(equalToConstant: 20),
            customVerticalProgressView.bottomAnchor.constraint(equalTo: titleView.topAnchor, constant: -8),
            
            // gramLabel을 프로그레스바 상단(머리)에 위치
            gramLabel.centerXAnchor.constraint(equalTo: customVerticalProgressView.centerXAnchor),
            gramLabel.bottomAnchor.constraint(equalTo: customVerticalProgressView.topAnchor, constant: -2), // 프로그레스바 바로 위
            
            // 타이틀을 하단에
            titleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 20),
            
        
            heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupHorizontalLayout(){
        addSubview(titleView)
        addSubview(progressContainer)
        progressContainer.addSubview(progressView)
        progressContainer.addSubview(gramLabel)
        
        NSLayoutConstraint.activate([
            titleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            progressContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressContainer.leadingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 4),
            progressContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressContainer.heightAnchor.constraint(equalToConstant: 20),
            
            progressView.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor),
            
            gramLabel.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor),
            gramLabel.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            gramLabel.leadingAnchor.constraint(greaterThanOrEqualTo: progressContainer.leadingAnchor, constant: 2),
            gramLabel.trailingAnchor.constraint(lessThanOrEqualTo: progressContainer.trailingAnchor, constant: -2),
            
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private var getNutrientType : NutrientEnums = NutrientEnums.CALRORIES
    func setNutrientType(_ type : NutrientEnums) {
        self.getNutrientType = type
    }
    
    private var consumeGram: Double = 0
    func setConsumeGram(_ grams: Double) {
        self.consumeGram = grams
    }
    
    private func updateUI(){
        titleView.text = NutritionSingleton.getNutritionName(getNutrientType)
        gramLabel.text = NutritionSingleton.getGramLabelText(consumeGram, type: getNutrientType)

        let progress = Float(min(consumeGram / NutritionSingleton.getMaxValueForNutrition(getNutrientType), 1.0))

        DispatchQueue.main.async {
            if self.isVertical {
                self.customVerticalProgressView.setProgress(progress, animated: true)
            } else {
                self.progressView.setProgress(progress, animated: true)
            }
        }
        
        setupGradientTextColor()
    }
    
    func updateConsumeGram(_ gram: Double) {
        self.consumeGram = gram
        updateUI()
    }
    
    private func setupGradientTextColor() {
        gramLabel.textColor = .white
        gramLabel.layer.shadowColor = UIColor.black.cgColor
        gramLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        gramLabel.layer.shadowOpacity = 0.8
        gramLabel.layer.shadowRadius = 2
        
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .strokeWidth: -1.5,
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]
        
        gramLabel.attributedText = NSAttributedString(
            string: gramLabel.text ?? "",
            attributes: strokeTextAttributes
        )
    }
}
