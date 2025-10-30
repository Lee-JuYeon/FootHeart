//
//  ThemeModel.swift
//  FootHeart
//
//  Created by Jupond on 5/22/25.
//
import CoreLocation

struct ThemeWalkingModel : Hashable {
    var uid : String
    var liked : [String]
    var themeTitle : String
    var themeImagePath : String
    var themeDescription : String
    var themeCourse : [CLLocation]
    var themeCreatorUID : String
    var themeThumbnailURL : String
    var themeCategory : ThemeCategory
    var duration : String
    var isLocked : Bool
}

enum ThemeCategory: String, CaseIterable {
    case nature = "자연"
    case city = "도시"
    case historical = "역사"
    case fitness = "피트니스"
    case meditation = "명상"
    
    var icon: String {
        switch self {
        case .nature: return "leaf.fill"
        case .city: return "building.2.fill"
        case .historical: return "building.columns.fill"
        case .fitness: return "figure.run"
        case .meditation: return "heart.fill"
        }
    }
}
