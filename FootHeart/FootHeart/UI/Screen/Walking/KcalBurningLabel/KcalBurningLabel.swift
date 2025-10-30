//
//  KcalBurningView.swift
//  FootHeart
//
//  Created by Jupond on 10/16/25.
//
import UIKit

class KcalBurningLabel : UILabel {
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textAlignment = .center
        textColor = .white  // black 텍스트
        text = "🔥 0Kcal"
        
        // Chip 스타일
        backgroundColor = .systemPink  // yellow 배경
        clipsToBounds = true
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
       
    private let stepKcalCalulator : StepCalorieCalculator = StepCalorieCalculator()
    private func getKcal(_ model: MapWalkingModel, bmiModel: BMIModel) -> Double {
        // ✅ 정밀 계산: 실제 속도와 시간 기반
        let calculateKcal = stepKcalCalulator.calculateCaloriesWithRealSpeed(
            mapWalkingModel: model,
            model: bmiModel
        )
        
        // 소숫점 첫째자리까지 반올림
        return round(calculateKcal * 10) / 10
    }
    
    func updateKcal(_ model: MapWalkingModel, bmiModel : BMIModel){
//        var updatedModel = bmiModel
//        updatedModel.steps = stepData.steps
//        text = "🔥 \(getKcal(stepData: stepData, bmiModel: updatedModel))Kcal"
        var updatedModel = bmiModel
        updatedModel.steps = model.steps
        
        // 걸음 수가 0이면 계산 불필요
        guard model.steps > 0 else {
            text = "🔥 0.0 Kcal"
            return
        }
        
        // ✅ BMI + 걸음 수 + 속도로 정밀 계산
        let kcal = getKcal(model, bmiModel: updatedModel)
        
        // UI 업데이트
        text = String(format: "🔥 %.1f Kcal", kcal)
        setNeedsDisplay()
        invalidateIntrinsicContentSize()
    }
   
    
    
}
