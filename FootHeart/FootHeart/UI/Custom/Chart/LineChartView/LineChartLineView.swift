//
//  LineChartLineView.swift
//  FootHeart
//
//  Created by Jupond on 8/24/25.
//
import UIKit

class LineChartLineView: UIView {
    
    var dataPoints: [LineChartData] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineColor: UIColor = .systemBlue
    
    override func draw(_ rect: CGRect) {
        guard dataPoints.count > 1 else { return } // 최소 2개 포인트 필요
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let (_, _, minY, maxY) = calculateDataRange()
        
        // 라인 스타일 설정
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(2.0)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        // 첫 번째 점으로 이동
        let firstPoint = dataPoints[0]
        let firstY = (1.0 - (firstPoint.y - minY) / (maxY - minY)) * rect.height
        let firstX = rect.width / CGFloat(dataPoints.count) * 0.5 // 셀 중앙
        context.move(to: CGPoint(x: firstX, y: firstY))
        
        // 나머지 점들로 선 그리기
        for i in 1..<dataPoints.count {
            let point = dataPoints[i]
            let y = (1.0 - (point.y - minY) / (maxY - minY)) * rect.height
            let x = rect.width / CGFloat(dataPoints.count) * (CGFloat(i) + 0.5)
            context.addLine(to: CGPoint(x: x, y: y))
        }
        
        context.strokePath() // 실제로 선 그리기
    }
    
    private func calculateDataRange() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let xValues = dataPoints.map { $0.x }
        let yValues = dataPoints.map { $0.y }
        
        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 1
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        
        let yRange = maxY - minY
        let yPadding = yRange * 0.1
        
        return (minX, maxX, minY - yPadding, maxY + yPadding)
    }
}

