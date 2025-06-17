//
//  ThemeWalkingRepository.swift
//  FootHeart
//
//  Created by Jupond on 6/11/25.
//

import Combine
import Foundation

class ThemeWalkingRepository : ThemeWalkingProtocol {
    
    private static var cachedThemes: [ThemeWalkingModel] = []
    private var hasCacheLoaded = false
    
    func fetchThemeWalkingList(page: Int, limit: Int) -> AnyPublisher<[ThemeWalkingModel], any Error> {
        return Future<[ThemeWalkingModel], Error> { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(NSError(
                    domain: "ThemeWalkingRepository",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Repository가 해제되었습니다."]
                )))
                return
            }
            
            // 네트워크 지연 시뮬레이션
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // 처음 로드시 DummyPack 데이터로 캐시 초기화
                if !self.hasCacheLoaded {
                    Self.cachedThemes = DummyPack.themeWalkingList()
                    self.hasCacheLoaded = true
                }
                
                let allThemes = Self.cachedThemes
                let startIndex = page * limit
                let endIndex = min(startIndex + limit, allThemes.count)
                
                if startIndex >= allThemes.count {
                    // 더 이상 데이터가 없음
                    promise(.success([]))
                } else {
                    let pageData = Array(allThemes[startIndex..<endIndex])
                    promise(.success(pageData))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addTheme(model: ThemeWalkingModel) -> AnyPublisher<Void, any Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(
                    domain: "ThemeWalkingRepository",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Repository가 해제되었습니다."]
                )))
                return
            }
            
            // 네트워크 지연 시뮬레이션
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                
                // 캐시가 로드되지 않았다면 먼저 로드
                if !self.hasCacheLoaded {
                    Self.cachedThemes = DummyPack.themeWalkingList()
                    self.hasCacheLoaded = true
                }
                
                // 새 테마를 리스트 맨 앞에 추가
                Self.cachedThemes.insert(model, at: 0)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 3. 리스트 새로고침 - DummyPack에서 최신 데이터 다시 로드
    func refreshThemeWalkingList() -> AnyPublisher<[ThemeWalkingModel], Error> {
        return Future<[ThemeWalkingModel], Error> { promise in
            // 네트워크 지연 시뮬레이션
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                
                // DummyPack에서 최신 데이터 다시 로드
                Self.cachedThemes = DummyPack.themeWalkingList()
                
                // 전체 리스트 반환 (첫 페이지용)
                promise(.success(Self.cachedThemes))
            }
        }
        .eraseToAnyPublisher()
    }
}
