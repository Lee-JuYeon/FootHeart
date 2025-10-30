//
//  WaterCheckView.swift
//  FootHeart
//
//  Created by Jupond on 9/5/25.
//
import Foundation
import UIKit

class WaterCheckView: UIView {
    
    // MARK: - Properties
    private var currentWaterIntake: Double = 0 // 현재 섭취량 (ml)
    private var dailyRecommendedIntake: Double = 2000 // 일일 권장량 (ml)
    private var progress: Double = 0 // 0.0 ~ 1.0
    
    // 콜백
    var onViewTapped: (() -> Void)?
    
    // 색상 설정
    private let backgroundColour = UIColor.systemGray4
    private let recommendedLineColor = UIColor.systemYellow
    private let progressColor = UIColor.systemBlue
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGesture)
        
        // 그림자 효과
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        
//        let bounds = rect
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        
//        // 물방울 모양 경로 생성
//        let waterDropPath = createWaterDropPath(in: bounds)
//        
//        // 배경 그리기 (회색)
//        context.setFillColor(backgroundColour.cgColor)
//        context.addPath(waterDropPath)
//        context.fillPath()
//        
//        // 권장량 표시선 그리기 (노란색)
//        drawRecommendedLine(context: context, bounds: bounds, path: waterDropPath)
//        
//        // 현재 진행도 표시 (하늘색)
//        drawProgress(context: context, bounds: bounds, path: waterDropPath)
//        
//        // 텍스트 표시
//        drawText(in: bounds)
        // 물방울 경로 생성
        // 컵 외곽
                let cupPath = UIBezierPath()
                let width = rect.width
                let height = rect.height
                
                // 컵 상단 좌우
                cupPath.move(to: CGPoint(x: width * 0.1, y: 0))
                cupPath.addLine(to: CGPoint(x: width * 0.9, y: 0))
                
                // 컵 측면
                cupPath.addLine(to: CGPoint(x: width * 0.8, y: height))
                cupPath.addLine(to: CGPoint(x: width * 0.2, y: height))
                cupPath.close()
                
                let cupLayer = CAShapeLayer()
                cupLayer.path = cupPath.cgPath
                cupLayer.strokeColor = UIColor.black.cgColor
                cupLayer.fillColor = UIColor.clear.cgColor
                cupLayer.lineWidth = 2
                self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.layer.addSublayer(cupLayer)
                
                // 물 채우기
                let waterHeight = height *  0.6
                let waterPath = UIBezierPath()
                waterPath.move(to: CGPoint(x: width * 0.2, y: height - waterHeight))
                waterPath.addLine(to: CGPoint(x: width * 0.8, y: height - waterHeight))
                waterPath.addLine(to: CGPoint(x: width * 0.8, y: height))
                waterPath.addLine(to: CGPoint(x: width * 0.2, y: height))
                waterPath.close()
                
                let waterLayer = CAShapeLayer()
                waterLayer.path = waterPath.cgPath
                waterLayer.fillColor = UIColor.systemBlue.cgColor
                self.layer.addSublayer(waterLayer)
    }
    
    private func createWaterDropPath(in bounds: CGRect) -> CGPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let centerX = bounds.midX
        
        // 물방울 모양 생성
        // 상단 둥근 부분 (원형)
        let circleRadius = width * 0.35
        let circleCenter = CGPoint(x: centerX, y: bounds.minY + circleRadius + height * 0.1)
        
        // 하단 점 부분
        let bottomPoint = CGPoint(x: centerX, y: bounds.maxY - height * 0.1)
        
        // 물방울 경로 그리기
        path.addArc(withCenter: circleCenter,
                   radius: circleRadius,
                   startAngle: 0,
                   endAngle: .pi,
                   clockwise: true)
        
        // 왼쪽 곡선
        path.addQuadCurve(to: bottomPoint,
                         controlPoint: CGPoint(x: centerX - circleRadius * 0.3,
                                             y: bottomPoint.y - height * 0.2))
        
        // 오른쪽 곡선
        path.addQuadCurve(to: CGPoint(x: centerX + circleRadius, y: circleCenter.y),
                         controlPoint: CGPoint(x: centerX + circleRadius * 0.3,
                                             y: bottomPoint.y - height * 0.2))
        
        path.close()
        
        return path.cgPath
    }
    
    private func drawRecommendedLine(context: CGContext, bounds: CGRect, path: CGPath) {
        // 권장량 80% 위치에 노란색 선 그리기
        let recommendedY = bounds.maxY - (bounds.height * 0.8) - bounds.height * 0.1
        
        context.setStrokeColor(recommendedLineColor.cgColor)
        context.setLineWidth(2.0)
        context.setLineDash(phase: 0, lengths: [5, 3])
        
        let lineStartX = bounds.midX - bounds.width * 0.25
        let lineEndX = bounds.midX + bounds.width * 0.25
        
        context.move(to: CGPoint(x: lineStartX, y: recommendedY))
        context.addLine(to: CGPoint(x: lineEndX, y: recommendedY))
        context.strokePath()
    }
    
    private func drawProgress(context: CGContext, bounds: CGRect, path: CGPath) {
        guard progress > 0 else { return }
        
        // 클리핑을 위한 progress 영역 계산
        let progressHeight = bounds.height * progress * 0.8 // 실제 물방울 영역의 80%만 사용
        let progressRect = CGRect(x: bounds.minX,
                                y: bounds.maxY - progressHeight - bounds.height * 0.1,
                                width: bounds.width,
                                height: progressHeight)
        
        // 물방울 모양으로 클리핑
        context.saveGState()
        context.addPath(path)
        context.clip()
        
        // 진행도 색상으로 채우기
        context.setFillColor(progressColor.cgColor)
        context.fill(progressRect)
        
        // 물결 효과 추가
        drawWaveEffect(context: context, in: progressRect, bounds: bounds)
        
        context.restoreGState()
    }
    
    private func drawWaveEffect(context: CGContext, in progressRect: CGRect, bounds: CGRect) {
        let waveHeight: CGFloat = 3
        let waveLength: CGFloat = bounds.width / 3
        let waveY = progressRect.minY
        
        let wavePath = UIBezierPath()
        wavePath.move(to: CGPoint(x: bounds.minX, y: waveY))
        
        for x in stride(from: bounds.minX, to: bounds.maxX, by: 1) {
            let relativeX = x - bounds.minX
            let wave = sin(relativeX / waveLength * .pi * 2) * waveHeight
            wavePath.addLine(to: CGPoint(x: x, y: waveY + wave))
        }
        
        wavePath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        wavePath.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        wavePath.close()
        
        context.setFillColor(progressColor.withAlphaComponent(0.8).cgColor)
        context.addPath(wavePath.cgPath)
        context.fillPath()
    }
    
    private func drawText(in bounds: CGRect) {
        let currentIntakeText = "\(Int(currentWaterIntake))ml"
        let recommendedText = "/ \(Int(dailyRecommendedIntake))ml"
        let percentageText = "\(Int(progress * 100))%"
        
        // 현재 섭취량 텍스트
        let currentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        let currentSize = currentIntakeText.size(withAttributes: currentAttributes)
        let currentRect = CGRect(x: bounds.midX - currentSize.width / 2,
                                y: bounds.midY - 20,
                                width: currentSize.width,
                                height: currentSize.height)
        
        currentIntakeText.draw(in: currentRect, withAttributes: currentAttributes)
        
        // 권장량 텍스트
        let recommendedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let recommendedSize = recommendedText.size(withAttributes: recommendedAttributes)
        let recommendedRect = CGRect(x: bounds.midX - recommendedSize.width / 2,
                                    y: bounds.midY + 5,
                                    width: recommendedSize.width,
                                    height: recommendedSize.height)
        
        recommendedText.draw(in: recommendedRect, withAttributes: recommendedAttributes)
        
        // 퍼센테이지 텍스트
        let percentageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: progressColor
        ]
        
        let percentageSize = percentageText.size(withAttributes: percentageAttributes)
        let percentageRect = CGRect(x: bounds.midX - percentageSize.width / 2,
                                   y: bounds.midY + 25,
                                   width: percentageSize.width,
                                   height: percentageSize.height)
        
        percentageText.draw(in: percentageRect, withAttributes: percentageAttributes)
    }
    
    // MARK: - Public Methods
    
    /// 방금 섭취한 수분량을 추가합니다
    /// - Parameter amount: 섭취한 수분량 (ml)
    func addWaterIntake(_ amount: Double) {
        currentWaterIntake = min(currentWaterIntake + amount, dailyRecommendedIntake * 1.5) // 최대 150%까지
        updateProgress()
        
        // 애니메이션과 함께 업데이트
        UIView.transition(with: self,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: {
            self.setNeedsDisplay()
        })
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
    
    /// 일일 권장 수분 섭취량을 설정합니다
    /// - Parameter amount: 권장량 (ml)
    func setDailyRecommendedIntake(_ amount: Double) {
        dailyRecommendedIntake = amount
        updateProgress()
        setNeedsDisplay()
    }
    
    /// 현재 수분 섭취량을 설정합니다
    /// - Parameter amount: 현재 섭취량 (ml)
    func setCurrentWaterIntake(_ amount: Double) {
        currentWaterIntake = amount
        updateProgress()
        setNeedsDisplay()
    }
    
    /// 현재 수분 섭취량을 반환합니다
    func getCurrentWaterIntake() -> Double {
        return currentWaterIntake
    }
    
    /// 일일 권장량을 반환합니다
    func getDailyRecommendedIntake() -> Double {
        return dailyRecommendedIntake
    }
    
    /// 현재 달성률을 반환합니다 (0.0 ~ 1.0)
    func getProgress() -> Double {
        return progress
    }
    
    /// 수분 섭취량을 초기화합니다
    func resetWaterIntake() {
        currentWaterIntake = 0
        updateProgress()
        setNeedsDisplay()
    }
    
    private func updateProgress() {
        progress = min(currentWaterIntake / dailyRecommendedIntake, 1.5) // 최대 150%
    }
    
    @objc private func viewTapped() {
        // 탭 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        onViewTapped?()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 160)
    }
}
