//
//  AudioPointModel.swift
//  FootHeart
//
//  Created by Jupond on 5/22/25.
//
import CoreLocation

struct AudioPointModel : Hashable {
    var uid : String
    var parentUID : String // AudioWalkingModel의 uid
    var location : CLLocation // 오디오 재생 포인트 지점
    var audioPath : String // 오디오 url
}
