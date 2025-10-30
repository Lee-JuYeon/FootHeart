//
//  FormatManager.swift
//  FootHeart
//
//  Created by Jupond on 9/8/25.
//
import Foundation

class FormatManager {
    static let shared = FormatManager()
    private init() {}

    func formatEatenTime(mealType: MealPatternType) -> String {
        let calendar = Calendar.current
        let now = Date() // 앱을 키는 현재 시점
        
        // 오늘, 어제 자동 판단
        if calendar.isDateInToday(now) {
            return "오늘 \(getMealTypeName(mealType))"
        } else if calendar.isDateInYesterday(now) {
            return "어제 \(getMealTypeName(mealType))"
        } else {
            // 그보다 과거는 날짜 형식으로
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: now)
        }
    }
    
    private func getMealTypeName(_ mealType: MealPatternType) -> String {
        switch mealType {
        case .BREAKFAST:
            return "아침"
        case .BRUNCH:
            return "브런치"
        case .LUNCH:
            return "점심"
        case .SNACK:
            return "간식"
        case .DINNER:
            return "저녁"
        case .MIDNIGHT_SNACK:
            return "야식"
        }
    }
}
