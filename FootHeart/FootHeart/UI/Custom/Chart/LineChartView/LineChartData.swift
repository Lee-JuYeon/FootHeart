//
//  LineChartData.swift
//  FootHeart
//
//  Created by Jupond on 8/24/25.
//

import UIKit

struct LineChartData {
    let x: CGFloat
    let y: CGFloat
    let label: String?
    
    init(x: CGFloat, y: CGFloat, label: String? = nil) {
        self.x = x
        self.y = y
        self.label = label
    }
}
