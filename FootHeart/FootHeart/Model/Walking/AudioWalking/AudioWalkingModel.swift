//
//  AudioWalkingModel.swift
//  FootHeart
//
//  Created by Jupond on 5/22/25.
//
import CoreLocation

struct AudioWalkingModel : Hashable {
    var uid : String
    var liked : [String] // 좋아요
    var description : String // 오디오 걷기 설명
    var mapSkinUID : String? = nil // 오디오 걷기 테마 스킨
    var backgroundMusicPath : String // 배경음악
    var playHighlightVideoURL : String  // 해당 audio walking 사용시 이팩트등 미리보기 (비디오)
    var audioActor : String // 성우
    var audioListenPreviewPath : String  // 오디오 미리 들어보기 (url)
    var audioWalkingPath : [CLLocation] // 오디오 걷기 코스
    var audioPointList : [AudioPointModel] // 오디오 걷기의 오디오 재생 포인트지점
}
