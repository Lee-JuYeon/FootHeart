//
//  BMIModel.swift
//  FootHeart
//
//  Created by Jupond on 10/20/25.
//
import Foundation

struct BMIModel: Codable {
    // 필수 입력값
    let weight: Double              // 체중 (kg)
    let height: Double?             // 키 (cm) - 보폭 추정에 사용
    var steps: Int                  // 걸음 수
    let age: Int?                   // 나이
    let isWomen: Bool?              // 성별 ( true = 여자 / false = 남자 )
    let baseCoefficient: Double     // 기본 계수 (기본값 0.57) = 칼로리 변환 보정값
    
    // 선택적 입력값
    let strideLength: Double?       // 보폭 (meters) - 없으면 체중 기반 추정
    let fatMass: Double?            // 체지방량 (kg)
    let leanMass: Double?           // 제지방량 (kg)
    let muscleMass: Double?         // 근육량 (kg)
    let fatPercent: Double?         // 체지방률 (%)
    let bmr: Double?                // 기초대사량 (kcal)
    let visceralFatIndex: Double?   // 내장지방지수
    
    init(weight: Double,
         steps: Int,
         baseCoefficient: Double = 0.57,
         strideLength: Double? = nil,
         fatMass: Double? = nil,
         leanMass: Double? = nil,
         muscleMass: Double? = nil,
         fatPercent: Double? = nil,
         bmr: Double? = nil,
         age: Int? = nil,
         visceralFatIndex: Double? = nil,
         height: Double? = nil,
         isWomen: Bool? = false
    ) {
        self.weight = weight
        self.steps = steps
        self.baseCoefficient = baseCoefficient
        self.strideLength = strideLength
        self.fatMass = fatMass
        self.leanMass = leanMass
        self.muscleMass = muscleMass
        self.fatPercent = fatPercent
        self.bmr = bmr
        self.age = age
        self.visceralFatIndex = visceralFatIndex
        self.height = height
        self.isWomen = isWomen
    }
}
