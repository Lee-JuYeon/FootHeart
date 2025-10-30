//
//  StepCalorieCaluculator.swift
//  FootHeart
//
//  Created by Jupond on 10/20/25.
//
import Foundation

/// 걸음 수 기반 칼로리 계산기
class StepCalorieCalculator {
    
    // MARK: - Constants
    
    /// MET 값 (Metabolic Equivalent of Task)
    private enum METValue {
        static let walking3km = 2.5      // 3 km/h
        static let walking4km = 3.0      // 4 km/h
        static let walking5km = 3.5      // 5 km/h
        static let walking6km = 4.5      // 6 km/h
    }
    
    /// 보폭 계산 계수
    private enum StrideCoefficient {
        static let male = 0.415          // 남성: 키(cm) × 0.415
        static let female = 0.413        // 여성: 키(cm) × 0.413
        static let weightBased = 0.43    // 체중 기반: 체중^0.43 × 0.7
    }
    
    // MARK: - Calculation Mode
    
    /// 칼로리 계산 모드
    enum CalculationMode {
        case standard    // 일반 체중계 (체중, 키, 나이, 성별)
        case advanced    // BMI 체중계 (체성분 포함)
        
        var description: String {
            switch self {
            case .standard:
                return "일반 체중계 모드 (BMR 기반)"
            case .advanced:
                return "BMI 체중계 모드 (체성분 기반)"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// BMIModel을 기반으로 소모 칼로리 계산
    /// - Parameter model: BMI 및 신체 정보 모델
    /// - Returns: 소모된 칼로리 (kcal)
    func calculateCalories(from model: BMIModel) -> Double {
        // 계산 모드 자동 판별
        let mode = determineCalculationMode(from: model)
        
        // 보폭 계산
        let stride = calculateStride(from: model)
        
        // 이동 거리 계산 (미터)
        let distance = stride * Double(model.steps)
        
        // 시간 및 속도 추정
        let averageStepsPerMinute = 110.0
        let timeInHours = Double(model.steps) / averageStepsPerMinute / 60.0
        let speedKmh = (distance / 1000.0) / timeInHours
        
        // MET 값 결정
        let met = determineMET(speed: speedKmh)
        
        // 모드에 따라 칼로리 계산
        switch mode {
        case .standard:
            return calculateStandardMode(model: model, met: met, timeInHours: timeInHours)
        case .advanced:
            return calculateAdvancedMode(model: model, met: met, timeInHours: timeInHours)
        }
    }
    
    /// 간단한 칼로리 계산 (체중과 걸음수만 사용)
    /// - Parameters:
    ///   - weight: 체중 (kg)
    ///   - steps: 걸음 수
    ///   - baseCoefficient: 기본 계수
    /// - Returns: 소모된 칼로리 (kcal)
    func calculateSimpleCalories(weight: Double, steps: Int, baseCoefficient: Double = 0.57) -> Double {
        return weight * Double(steps) * baseCoefficient / 1000.0
    }
    
    // MARK: - Mode Determination
    
    /// 입력 데이터에 따라 계산 모드 결정
    /// - Parameter model: BMI 모델
    /// - Returns: 계산 모드
    private func determineCalculationMode(from model: BMIModel) -> CalculationMode {
        // BMI 체중계 데이터가 하나라도 있으면 Advanced 모드
        if model.fatMass != nil ||
           model.leanMass != nil ||
           model.muscleMass != nil ||
           model.fatPercent != nil ||
           model.bmr != nil ||
           model.visceralFatIndex != nil {
            return .advanced
        }
        
        // 그 외는 Standard 모드 (일반 체중계)
        return .standard
    }
    
    // MARK: - Standard Mode (일반 체중계)
    
    /// 일반 체중계 모드: BMR 기반 계산
    /// - 입력: 체중, 키, 나이, 성별
    /// - 계산: Harris-Benedict 공식으로 BMR 계산 후 칼로리 산출
    private func calculateStandardMode(model: BMIModel, met: Double, timeInHours: Double) -> Double {
        // BMR 계산
        let bmr: Double
        if let inputBMR = model.bmr {
            // 사용자가 직접 입력한 BMR
            bmr = inputBMR
        } else if let height = model.height, let age = model.age, let isWomen = model.isWomen {
            // Harris-Benedict 공식으로 BMR 계산
            if isWomen {
                // 여성: 447.593 + (9.247 × 체중) + (3.098 × 키) - (4.330 × 나이)
                bmr = 447.593 + (9.247 * model.weight) + (3.098 * height) - (4.330 * Double(age))
            } else {
                // 남성: 88.362 + (13.397 × 체중) + (4.799 × 키) - (5.677 × 나이)
                bmr = 88.362 + (13.397 * model.weight) + (4.799 * height) - (5.677 * Double(age))
            }
        } else {
            // BMR 계산 불가능 시 간소화된 추정
            bmr = estimateBMRSimple(weight: model.weight, age: model.age, isWomen: model.isWomen)
        }
        
        // 칼로리 = (MET × BMR / 24) × 시간
        var calories = (met * bmr / 24.0) * timeInHours
        
        // 기본 계수 적용
        calories *= model.baseCoefficient
        
        return calories
    }
    
    /// 간소화된 BMR 추정 (키 정보 없을 때)
    private func estimateBMRSimple(weight: Double, age: Int?, isWomen: Bool?) -> Double {
        let baseCalories: Double
        if let isWomen = isWomen {
            baseCalories = isWomen ? (10 * weight + 500) : (10 * weight + 900)
        } else {
            baseCalories = 10 * weight + 700
        }
        
        if let age = age {
            return baseCalories - (6.25 * Double(age))
        }
        
        return baseCalories
    }
    
    // MARK: - Advanced Mode (BMI 체중계)
    
    /// BMI 체중계 모드: 체성분 기반 계산
    /// - 입력: 체중 + 체성분 데이터 (체지방량, 제지방량, 근육량, 체지방률 등)
    /// - 계산: 제지방량 기반으로 정밀한 칼로리 산출
    private func calculateAdvancedMode(model: BMIModel, met: Double, timeInHours: Double) -> Double {
        // 1. 제지방량 결정
        let leanMass = getLeanMass(from: model)
        
        // 2. 제지방량 기반 칼로리 계산
        // 공식: 칼로리 = MET × 제지방량(kg) × 시간 × 5.0
        var calories = met * leanMass * timeInHours * 5.0
        
        // 3. 나이 보정
        if let age = model.age {
            let ageAdjustment = 1.0 - (Double(age - 20) * 0.005)
            calories *= max(0.7, ageAdjustment)  // 최소 70%까지만 감소
        }
        
        // 4. 성별 보정
        if let isWomen = model.isWomen {
            calories *= isWomen ? 0.9 : 1.0
        }
        
        // 5. 내장지방 보정
        if let visceralFat = model.visceralFatIndex {
            let visceralAdjustment = 1.0 - (min(visceralFat, 15.0) / 150.0)
            calories *= visceralAdjustment
        }
        
        // 6. 기본 계수 적용
        calories *= model.baseCoefficient
        
        return calories
    }
    
    /// 제지방량 결정 (우선순위에 따라)
    private func getLeanMass(from model: BMIModel) -> Double {
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
        
        // 4순위: 근육량으로부터 추정 (근육량은 제지방량의 약 55%)
        if let muscleMass = model.muscleMass {
            return muscleMass / 0.55
        }
        
        // 5순위: BMR로부터 역산 (참고용)
        if let bmr = model.bmr {
            // Katch-McArdle 공식 역산: BMR ≈ 370 + (21.6 × 제지방량)
            return (bmr - 370.0) / 21.6
        }
        
        // 6순위: 기본 추정치 (체중의 75%)
        return model.weight * 0.75
    }
    
    // MARK: - Stride Calculation
    
    /// 보폭 계산
    private func calculateStride(from model: BMIModel) -> Double {
        // 1순위: 직접 입력된 보폭
        if let stride = model.strideLength {
            return stride
        }
        
        // 2순위: 키 기반 계산
        if let height = model.height {
            let coefficient = (model.isWomen ?? false) ?
                StrideCoefficient.female : StrideCoefficient.male
            return height * coefficient / 100.0  // cm를 m로 변환
        }
        
        // 3순위: 체중 기반 추정
        return pow(model.weight, StrideCoefficient.weightBased) * 0.7
    }
    
    // MARK: - MET Determination
    
    /// 속도에 따른 MET 값 결정
    private func determineMET(speed: Double) -> Double {
        switch speed {
        case 0..<3.5: return METValue.walking3km
        case 3.5..<4.5: return METValue.walking4km
        case 4.5..<5.5: return METValue.walking5km
        default: return METValue.walking6km
        }
    }
    
    // MARK: - Helper Methods
    
    /// 거리 계산
    func calculateDistance(from model: BMIModel) -> Double {
        let stride = calculateStride(from: model)
        return stride * Double(model.steps)
    }
    
    /// 예상 시간 계산
    func estimateTime(from model: BMIModel) -> Double {
        return Double(model.steps) / 110.0  // 분 단위
    }
    
    /// 평균 속도 계산
    func calculateAverageSpeed(from model: BMIModel) -> Double {
        let distance = calculateDistance(from: model)  // 미터
        let timeInHours = estimateTime(from: model) / 60.0
        return (distance / 1000.0) / timeInHours  // km/h
    }
}

// MARK: - Extension for Detailed Results

extension StepCalorieCalculator {
    
    /// 칼로리 계산 상세 결과
    struct CalorieResult {
        let calories: Double              // 소모 칼로리 (kcal)
        let distance: Double              // 이동 거리 (m)
        let estimatedTime: Double         // 예상 시간 (분)
        let averageSpeed: Double          // 평균 속도 (km/h)
        let stride: Double                // 보폭 (m)
        let mode: CalculationMode         // 계산 모드
        let bmr: Double?                  // BMR (Standard 모드일 때)
        let leanMass: Double?             // 제지방량 (Advanced 모드일 때)
    }
    
    /// HybridStepTracker의 실제 측정 데이터로 칼로리 계산
    /// - Parameters:
    ///   - stepData: HybridStepTracker의 StepData
    ///   - model: BMI 모델
    /// - Returns: 소모된 칼로리 (kcal)
    func calculateCaloriesWithRealSpeed(
        mapWalkingModel: MapWalkingModel,
        model: BMIModel
    ) -> Double {
        let mode = determineCalculationMode(from: model)
        
        // 🎯 실제 측정된 평균 속도 사용 (km/h)
        let realSpeedKmh = mapWalkingModel.averageSpeed

        // 🔥 시간 계산: elapsedTime이 있으면 사용, 없으면 걸음 수로 추정
        let timeInHours: Double
        if mapWalkingModel.duration > 0 {
            timeInHours = mapWalkingModel.duration / 3600.0
        } else {
            // 걸음 수로부터 시간 추정 (평균 분당 110걸음)
            let averageStepsPerMinute = 110.0
            timeInHours = Double(model.steps) / averageStepsPerMinute / 60.0
        }
        
        // 실제 속도로 MET 값 결정
        let met = determineMET(speed: realSpeedKmh)
        
        // 모드에 따라 칼로리 계산
        switch mode {
        case .standard:
            return calculateStandardMode(model: model, met: met, timeInHours: timeInHours)
        case .advanced:
            return calculateAdvancedMode(model: model, met: met, timeInHours: timeInHours)
        }
    }
    
    /// 상세한 칼로리 계산 결과 반환
    func calculateDetailedResult(from model: BMIModel) -> CalorieResult {
        let mode = determineCalculationMode(from: model)
        let calories = calculateCalories(from: model)
        let distance = calculateDistance(from: model)
        let time = estimateTime(from: model)
        let speed = calculateAverageSpeed(from: model)
        let stride = calculateStride(from: model)
        
        var bmr: Double? = nil
        var leanMass: Double? = nil
        
        switch mode {
        case .standard:
            // BMR 계산
            if let inputBMR = model.bmr {
                bmr = inputBMR
            } else if let height = model.height,
                      let age = model.age,
                      let isWomen = model.isWomen {
                if isWomen {
                    bmr = 447.593 + (9.247 * model.weight) + (3.098 * height) - (4.330 * Double(age))
                } else {
                    bmr = 88.362 + (13.397 * model.weight) + (4.799 * height) - (5.677 * Double(age))
                }
            }
            
        case .advanced:
            // 제지방량 계산
            leanMass = getLeanMass(from: model)
        }
        
        return CalorieResult(
            calories: calories,
            distance: distance,
            estimatedTime: time,
            averageSpeed: speed,
            stride: stride,
            mode: mode,
            bmr: bmr,
            leanMass: leanMass
        )
    }
}
