//
//  CurrentWalkingModel.swift
//  FootHeart
//
//  Created by Jupond on 5/22/25.
//

import CoreLocation

struct CurrentWalkingModel : Hashable {
    var walkingCount : Int
    var walkingPath : [CLLocation]
}
