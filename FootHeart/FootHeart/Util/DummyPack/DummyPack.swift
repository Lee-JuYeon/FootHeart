//
//  DummyPack.swift
//  FootHeart
//
//  Created by Jupond on 6/11/25.
//
import CoreLocation

class DummyPack {
    
    // MARK: - Singleton Instance
    static let shared = DummyPack()
    
    static func themeWalkingList() -> [ThemeWalkingModel] {
        return [
            // 자연 테마들
            ThemeWalkingModel(
                uid: "theme_001",
                liked: ["user1", "user2", "user3", "user7", "user12"],
                themeTitle: "한강 서래섬 힐링 코스",
                themeImagePath: "hangang_serae",
                themeDescription: "한강의 아름다운 서래섬을 따라 걷는 평화로운 힐링 코스입니다. 자연과 함께하는 여유로운 시간을 만끽하세요.",
                themeCourse:  [
                    CLLocation(latitude: 37.5172, longitude: 127.0286), // 서래섬 시작점
                    CLLocation(latitude: 37.5175, longitude: 127.0290),
                    CLLocation(latitude: 37.5180, longitude: 127.0295),
                    CLLocation(latitude: 37.5185, longitude: 127.0300),
                    CLLocation(latitude: 37.5190, longitude: 127.0305),
                    CLLocation(latitude: 37.5195, longitude: 127.0310), // 서래섬 끝점
                ],
                themeCreatorUID: "creator_001",
                themeThumbnailURL: "https://example.com/thumbnails/hangang_serae.jpg",
                themeCategory: .nature,
                duration: "45분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_002",
                liked: ["user4", "user5", "user8"],
                themeTitle: "남산 둘레길 자연 산책",
                themeImagePath: "namsan_trail",
                themeDescription: "서울 시내에서 만나는 자연, 남산 둘레길을 따라 걷는 상쾌한 산책 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5505, longitude: 126.9909), // 남산 둘레길 시작
                    CLLocation(latitude: 37.5510, longitude: 126.9915),
                    CLLocation(latitude: 37.5515, longitude: 126.9920),
                    CLLocation(latitude: 37.5520, longitude: 126.9925),
                    CLLocation(latitude: 37.5525, longitude: 126.9930),
                    CLLocation(latitude: 37.5530, longitude: 126.9935),
                    CLLocation(latitude: 37.5535, longitude: 126.9940),
                ],
                themeCreatorUID: "creator_002",
                themeThumbnailURL: "https://example.com/thumbnails/namsan_trail.jpg",
                themeCategory: .nature,
                duration: "60분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_003",
                liked: ["user1", "user9", "user10", "user15"],
                themeTitle: "청계천 도심 산책로",
                themeImagePath: "cheonggyecheon",
                themeDescription: "도심 속 오아시스 청계천을 따라 걷는 도시 재생의 상징적 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5697, longitude: 126.9783), // 청계천 시작점
                    CLLocation(latitude: 37.5700, longitude: 126.9800),
                    CLLocation(latitude: 37.5703, longitude: 126.9820),
                    CLLocation(latitude: 37.5706, longitude: 126.9840),
                    CLLocation(latitude: 37.5709, longitude: 126.9860),
                ],
                themeCreatorUID: "creator_003",
                themeThumbnailURL: "",
                themeCategory: .city,
                duration: "30분",
                isLocked: false
            ),
            
            // 역사 테마들
            ThemeWalkingModel(
                uid: "theme_004",
                liked: ["user2", "user6", "user11", "user13", "user16", "user20"],
                themeTitle: "경복궁 역사 탐방",
                themeImagePath: "gyeongbokgung",
                themeDescription: "조선 왕조의 정궁 경복궁을 둘러보며 500년 역사를 체험하는 문화 산책입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5788, longitude: 126.9770), // 경복궁 정문
                    CLLocation(latitude: 37.5790, longitude: 126.9775),
                    CLLocation(latitude: 37.5795, longitude: 126.9780),
                    CLLocation(latitude: 37.5800, longitude: 126.9785),
                    CLLocation(latitude: 37.5805, longitude: 126.9790),
                    CLLocation(latitude: 37.5810, longitude: 126.9795),
                    CLLocation(latitude: 37.5815, longitude: 126.9800),
                    CLLocation(latitude: 37.5820, longitude: 126.9805),
                ],
                themeCreatorUID: "creator_004",
                themeThumbnailURL: "https://example.com/thumbnails/gyeongbokgung.jpg",
                themeCategory: .historical,
                duration: "90분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_005",
                liked: ["user3", "user7", "user14"],
                themeTitle: "북촌 한옥마을 골목길",
                themeImagePath: "bukchon_hanok",
                themeDescription: "전통과 현대가 공존하는 북촌 한옥마을의 아름다운 골목길을 거닐어보세요.",
                themeCourse: [
                    CLLocation(latitude: 37.5814, longitude: 126.9834), // 북촌 한옥마을
                    CLLocation(latitude: 37.5820, longitude: 126.9840),
                    CLLocation(latitude: 37.5825, longitude: 126.9845),
                    CLLocation(latitude: 37.5830, longitude: 126.9850),
                    CLLocation(latitude: 37.5835, longitude: 126.9855),
                    CLLocation(latitude: 37.5840, longitude: 126.9860),
                ],
                themeCreatorUID: "creator_005",
                themeThumbnailURL: "https://example.com/thumbnails/bukchon_hanok.jpg",
                themeCategory: .historical,
                duration: "75분",
                isLocked: false
            ),
            
            // 도시 테마들
            ThemeWalkingModel(
                uid: "theme_006",
                liked: ["user5", "user8", "user12", "user17"],
                themeTitle: "홍대 문화의 거리",
                themeImagePath: "hongdae_culture",
                themeDescription: "젊음과 예술이 살아 숨쉬는 홍대 문화의 거리를 탐험하는 활기찬 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5563, longitude: 126.9236), // 홍대입구역
                    CLLocation(latitude: 37.5568, longitude: 126.9240),
                    CLLocation(latitude: 37.5573, longitude: 126.9245),
                    CLLocation(latitude: 37.5578, longitude: 126.9250),
                    CLLocation(latitude: 37.5583, longitude: 126.9255),
                ],
                themeCreatorUID: "creator_006",
                themeThumbnailURL: "",
                themeCategory: .city,
                duration: "50분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_007",
                liked: ["user1", "user4", "user9", "user18", "user21"],
                themeTitle: "강남 테헤란로 비즈니스",
                themeImagePath: "gangnam_teheran",
                themeDescription: "한국의 실리콘밸리 테헤란로를 걸으며 현대 한국의 역동성을 느껴보세요.",
                themeCourse: [
                    CLLocation(latitude: 37.5048, longitude: 127.0280), // 테헤란로 시작
                    CLLocation(latitude: 37.5053, longitude: 127.0285),
                    CLLocation(latitude: 37.5058, longitude: 127.0290),
                    CLLocation(latitude: 37.5063, longitude: 127.0295),
                    CLLocation(latitude: 37.5068, longitude: 127.0300),
                ],
                themeCreatorUID: "creator_007",
                themeThumbnailURL: "https://example.com/thumbnails/gangnam_teheran.jpg",
                themeCategory: .city,
                duration: "40분",
                isLocked: false
            ),
            
            // 피트니스 테마들
            ThemeWalkingModel(
                uid: "theme_008",
                liked: ["user6", "user10", "user19"],
                themeTitle: "올림픽공원 체력 단련",
                themeImagePath: "olympic_park_fitness",
                themeDescription: "넓은 올림픽공원에서 체력 단련과 함께하는 건강한 워킹 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5201, longitude: 127.1216), // 올림픽공원
                    CLLocation(latitude: 37.5206, longitude: 127.1220),
                    CLLocation(latitude: 37.5211, longitude: 127.1225),
                    CLLocation(latitude: 37.5216, longitude: 127.1230),
                    CLLocation(latitude: 37.5221, longitude: 127.1235),
                    CLLocation(latitude: 37.5226, longitude: 127.1240),
                    CLLocation(latitude: 37.5231, longitude: 127.1245),
                ],
                themeCreatorUID: "creator_008",
                themeThumbnailURL: "https://example.com/thumbnails/olympic_park.jpg",
                themeCategory: .fitness,
                duration: "80분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_009",
                liked: ["user2", "user11", "user14", "user22"],
                themeTitle: "반포 한강공원 조깅",
                themeImagePath: "banpo_hangang_jogging",
                themeDescription: "반포 한강공원의 조깅 코스를 따라 걷는 체력 향상 프로그램입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5133, longitude: 126.9918), // 반포 한강공원
                    CLLocation(latitude: 37.5138, longitude: 126.9923),
                    CLLocation(latitude: 37.5143, longitude: 126.9928),
                    CLLocation(latitude: 37.5148, longitude: 126.9933),
                    CLLocation(latitude: 37.5153, longitude: 126.9938),
                ],
                themeCreatorUID: "creator_009",
                themeThumbnailURL: "",
                themeCategory: .fitness,
                duration: "55분",
                isLocked: false
            ),
            
            // 명상 테마들
            ThemeWalkingModel(
                uid: "theme_010",
                liked: ["user3", "user13", "user15", "user20", "user23"],
                themeTitle: "조계사 템플스테이 걷기",
                themeImagePath: "jogyesa_temple",
                themeDescription: "도심 속 사찰 조계사에서 마음의 평화를 찾는 명상 걷기 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5735, longitude: 126.9832), // 조계사
                    CLLocation(latitude: 37.5740, longitude: 126.9835),
                    CLLocation(latitude: 37.5745, longitude: 126.9838),
                    CLLocation(latitude: 37.5750, longitude: 126.9841),
                ],
                themeCreatorUID: "creator_010",
                themeThumbnailURL: "https://example.com/thumbnails/jogyesa_temple.jpg",
                themeCategory: .meditation,
                duration: "35분",
                isLocked: false
            ),
            
            ThemeWalkingModel(
                uid: "theme_011",
                liked: ["user7", "user16", "user24"],
                themeTitle: "선유도공원 명상 산책",
                themeImagePath: "seonyudo_meditation",
                themeDescription: "물과 자연이 어우러진 선유도공원에서 명상하며 걷는 힐링 코스입니다.",
                themeCourse: [
                    CLLocation(latitude: 37.5434, longitude: 126.8952), // 선유도공원
                    CLLocation(latitude: 37.5439, longitude: 126.8957),
                    CLLocation(latitude: 37.5444, longitude: 126.8962),
                    CLLocation(latitude: 37.5449, longitude: 126.8967),
                    CLLocation(latitude: 37.5454, longitude: 126.8972),
                ],
                themeCreatorUID: "creator_011",
                themeThumbnailURL: "https://example.com/thumbnails/seonyudo_park.jpg",
                themeCategory: .meditation,
                duration: "65분",
                isLocked: false
            ),
            
            // 잠금된 프리미엄 테마들
            ThemeWalkingModel(
                uid: "theme_012",
                liked: ["user1", "user5", "user12", "user18", "user25", "user26", "user27"],
                themeTitle: "북한산 정상 도전 코스",
                themeImagePath: "bukhansan_premium",
                themeDescription: "북한산 정상을 목표로 하는 도전적인 프리미엄 트레킹 코스입니다. 완주 시 특별한 보상이 주어집니다.",
                themeCourse: [
                    CLLocation(latitude: 37.6587, longitude: 126.9774), // 북한산 등산로 시작
                    CLLocation(latitude: 37.6592, longitude: 126.9779),
                    CLLocation(latitude: 37.6597, longitude: 126.9784),
                    CLLocation(latitude: 37.6602, longitude: 126.9789),
                    CLLocation(latitude: 37.6607, longitude: 126.9794),
                    CLLocation(latitude: 37.6612, longitude: 126.9799),
                    CLLocation(latitude: 37.6617, longitude: 126.9804),
                    CLLocation(latitude: 37.6622, longitude: 126.9809),
                    CLLocation(latitude: 37.6627, longitude: 126.9814), // 정상
                ],
                themeCreatorUID: "creator_premium",
                themeThumbnailURL: "https://example.com/thumbnails/bukhansan_premium.jpg",
                themeCategory: .fitness,
                duration: "180분",
                isLocked: true
            )
        ]
    }
       
        
}
