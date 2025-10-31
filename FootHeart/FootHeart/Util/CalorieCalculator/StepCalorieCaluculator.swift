//
//  StepCalorieCaluculator.swift
//  FootHeart
//
//  Created by Jupond on 10/20/25.
//
import Foundation

// 걸음 수 기반 칼로리 계산기
class StepCalorieCalculator {
    
    // MARK: - Constants
    
    // MET 값 (보수적 기준)
    private enum METValue {
        static let slowWalking = 2.0      // < 3km/h
        static let normalWalking = 2.5    // 3-4km/h
        static let briskWalking = 3.0     // 4-5km/h
        static let veryBriskWalking = 3.5 // 5-6km/h
        static let lightJogging = 4.0     // 6km/h 이상
    }
    
    // MARK: - Public Methods
    
    // 실제 측정 데이터로 칼로리 계산 (BMI 데이터 활용)
    func calculateCaloriesWithRealSpeed(
        mapWalkingModel: MapWalkingModel,
        model: BMIModel
    ) -> Double {
        // 시간 체크
        guard mapWalkingModel.duration > 0 else {
            return 0
        }
        
        // 시간 계산 (시간 단위)
        let timeInHours = mapWalkingModel.duration / 3600.0
        
        // 속도 계산 (m/s → km/h)
        let speedKmh = mapWalkingModel.averageSpeed * 3.6
        
        // MET 값 결정
        let met = determineMET(speed: speedKmh)
        
        // BMI 데이터 유무에 따라 계산 방식 선택
        if hasBMIData(model) {
            return calculateWithBMIData(model: model, met: met, timeInHours: timeInHours)
        } else {
            return calculateStandard(model: model, met: met, timeInHours: timeInHours)
        }
    }
    
    // 걸음 수만으로 칼로리 계산
    func calculateCalories(from model: BMIModel) -> Double {
        guard model.steps > 0 else {
            return 0
        }
        
        let stride = calculateStride(from: model)
        let distance = stride * Double(model.steps)
        let averageStepsPerMinute = 110.0
        let timeInHours = Double(model.steps) / averageStepsPerMinute / 60.0
        let speedKmh = (distance / 1000.0) / timeInHours
        let met = determineMET(speed: speedKmh)
        
        if hasBMIData(model) {
            return calculateWithBMIData(model: model, met: met, timeInHours: timeInHours)
        } else {
            return calculateStandard(model: model, met: met, timeInHours: timeInHours)
        }
    }
    
    // MARK: - Private Calculation Methods
    
    // BMI 체중계 데이터 유무 확인
    private func hasBMIData(_ model: BMIModel) -> Bool {
        return model.leanMass != nil ||
               model.fatPercent != nil ||
               model.muscleMass != nil ||
               model.fatMass != nil
    }
    
    // BMI 데이터 활용한 칼로리 계산 (보수적)
    private func calculateWithBMIData(model: BMIModel, met: Double, timeInHours: Double) -> Double {
        // 기본 칼로리: MET × 체중 × 시간
        var calories = met * model.weight * timeInHours
        
        // 제지방량 비율 보정 (보수적)
        // 제지방량이 많을수록 칼로리 소모가 높지만, 보수적으로 최대 +10%까지만
        if let leanMass = getLeanMass(from: model) {
            let leanMassRatio = leanMass / model.weight
            // 0.5 ~ 0.8 범위: 0.95 ~ 1.05 배율 적용 (보수적)
            let adjustment = 0.95 + (min(max(leanMassRatio, 0.5), 0.8) - 0.5) * 0.33
            calories *= adjustment
        }
        
        // 나이 보정 (보수적)
        // 나이가 들수록 대사량 감소, 하지만 보수적으로 최대 -10%까지만
        if let age = model.age {
            if age > 30 {
                let ageAdjustment = 1.0 - (Double(age - 30) * 0.003)  // 나이당 -0.3%
                calories *= max(0.90, ageAdjustment)  // 최소 90%까지만 감소
            }
        }
        
        // 성별 보정 (보수적)
        // 여성은 평균적으로 대사량이 약간 낮지만, 보수적으로 -5%만 적용
        if let isWomen = model.isWomen, isWomen {
            calories *= 0.95
        }
        
        return calories
    }
    
    // 표준 칼로리 계산 (BMI 데이터 없을 때)
    private func calculateStandard(model: BMIModel, met: Double, timeInHours: Double) -> Double {
        // 기본 칼로리: MET × 체중 × 시간
        var calories = met * model.weight * timeInHours
        
        // 나이 보정만 적용 (보수적)
        if let age = model.age {
            if age > 30 {
                let ageAdjustment = 1.0 - (Double(age - 30) * 0.003)
                calories *= max(0.90, ageAdjustment)
            }
        }
        
        // 성별 보정 (보수적)
        if let isWomen = model.isWomen, isWomen {
            calories *= 0.95
        }
        
        return calories
    }
    
    // 제지방량 결정 (우선순위)
    private func getLeanMass(from model: BMIModel) -> Double? {
        // 1순위: 직접 입력된 제지방량
        if let leanMass = model.leanMass {
            return leanMass
        }
        
        // 2순위: 체지방률로부터 계산
        if let fatPercent = model.fatPercent {
            return model.weight * (1.0 - fatPercent / 100.0)
        }
        
        // 3순위: 체지방량으로부터 계산
        if let fatMass = model.fatMass {
            return model.weight - fatMass
        }
        
        // 4순위: 근육량으로부터 추정 (근육량은 제지방량의 약 50-60%)
        if let muscleMass = model.muscleMass {
            return muscleMass / 0.55
        }
        
        return nil
    }
    
    // 속도 기반 MET 값 결정 (보수적)
    private func determineMET(speed: Double) -> Double {
        switch speed {
        case 0..<3.0:
            return METValue.slowWalking        // 2.0
        case 3.0..<4.0:
            return METValue.normalWalking      // 2.5
        case 4.0..<5.0:
            return METValue.briskWalking       // 3.0
        case 5.0..<6.0:
            return METValue.veryBriskWalking   // 3.5
        default:
            return METValue.lightJogging       // 4.0
        }
    }
    
    // 보폭 계산
    private func calculateStride(from model: BMIModel) -> Double {
        // 1순위: 직접 입력된 보폭
        if let stride = model.strideLength {
            return stride
        }
        
        // 2순위: 키 기반 계산
        if let height = model.height {
            let coefficient = (model.isWomen ?? false) ? 0.413 : 0.415
            return height * coefficient / 100.0
        }
        
        // 3순위: 기본값
        return 0.7
    }
    
    // MARK: - Helper Methods
    
    // 거리 계산 (미터)
    func calculateDistance(from model: BMIModel) -> Double {
        let stride = calculateStride(from: model)
        return stride * Double(model.steps)
    }
    
    // 예상 시간 계산 (분)
    func estimateTime(from model: BMIModel) -> Double {
        return Double(model.steps) / 110.0
    }
    
    // 평균 속도 계산 (km/h)
    func calculateAverageSpeed(from model: BMIModel) -> Double {
        let distance = calculateDistance(from: model)
        let timeInHours = estimateTime(from: model) / 60.0
        return (distance / 1000.0) / timeInHours
    }
}
