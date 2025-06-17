//
//  WalkingProtocol.swift
//  FootHeart
//
//  Created by Jupond on 5/21/25.
//
import Foundation






protocol WalkingProtocol {
    // 실시간 현재 걸음 수 측정
    func loadCurrentWalkingCount(completion: @escaping (Result<CurrentWalkingModel, Error>) -> Void)
    // 실시간 현재 걸음 경로 측정
    func loadCurrentWalkingPath(completion: @escaping (Result<CurrentWalkingModel, Error>) -> Void)
    
    // 테마 리스트
    func loadThemeList(completion: @escaping (Result<[ThemeWalkingModel], Error>) -> Void)
    // 현재 테마 걷기
    func loadCurrentTheme(completion: @escaping (Result<ThemeWalkingModel, Error>) -> Void)
    
    // 오디오 걷기 리스트
    func loadAudioWalkingList(completion: @escaping (Result<[AudioWalkingModel], Error>) -> Void)

}
