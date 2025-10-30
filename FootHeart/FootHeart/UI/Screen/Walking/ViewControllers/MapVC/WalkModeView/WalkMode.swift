//
//  WalkMode.swift
//  FootHeart
//
//  Created by Jupond on 10/25/25.
//


enum WalkMode : Codable {
    case WALK
    case RUN
    case BICYCLE
    
    var icon: String {
        switch self {
        case .WALK: return "🚶🏻"
        case .RUN: return "🏃🏻"
        case .BICYCLE: return "🚴🏻"
        }
    }
    
    var title: String {
        switch self {
        case .WALK: return "걷기"
        case .RUN: return "달리기"
        case .BICYCLE: return "자전거"
        }
    }
}
