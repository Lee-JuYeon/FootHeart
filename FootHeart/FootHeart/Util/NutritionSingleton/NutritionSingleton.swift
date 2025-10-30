//
//  NutritionSingleton.swift
//  FootHeart
//
//  Created by Jupond on 8/21/25.
//

class NutritionSingleton {
    static let shared = NutritionSingleton()
    private init() {}

    static func getGramLabelText(_ currentGram : Double, type nutrientType : NutrientEnums) -> String{
//        // 현재 섭취량 라벨 업데이트
//        let consumedNutrition =  "\(String(format: "%.1f", currentGram))\(getNutritionUnit(nutrientType))"
//        let maximunNutrition = "\(String(format: "%.0f", getMaxValueForNutrition(nutrientType)))\(getNutritionUnit(nutrientType))"
//        
//        return "\(consumedNutrition) / \(maximunNutrition)"
        // 현재 섭취량 라벨 업데이트
        let consumedNutrition =  "\(String(format: "%.1f", currentGram))\(getNutritionUnit(nutrientType))"
        let maximunNutrition = "\(String(format: "%.0f", getMaxValueForNutrition(nutrientType)))\(getNutritionUnit(nutrientType))"
        
        return "\(consumedNutrition)"
    }
    
    static func getNutritionName(_ nutritionType : NutrientEnums) -> String {
       switch nutritionType {
       case .CALRORIES:
           return "칼로리"
       case .PROTEIN:
           return "단백질"
       case .CARBOHYDRATES:
           return "탄수화물"
       case .CARBOHYDRATES_DIETARY_FIBER:
           return "식이섬유"
       case .CARBOHYDRATES_TOTAL_SUGAR:
           return "총당류"
       case .CARBOHYDRATES_INCLUDE_ADDED_SUGAR:
           return "첨가당"
       case .FAT:
           return "지방"
       case .FAT_TRANS_FAT:
           return "트랜스지방"
       case .FAT_SATURATE_FAT:
           return "포화지방"
       case .SODIUM:
           return "나트륨"
       case .CHOLESTEROL:
           return "콜레스테롤"
       case .IRON:
           return "철분"
       case .CALCIUM:
           return "칼슘"
       case .POTASSIUM:
           return "칼륨"
       case .VITAMIN:
           return "비타민"
       case .VITAMIN_A:
           return "비타민 A"
       case .VITAMIN_B1:
           return "비타민 B1"
       case .VITAMIN_B2:
           return "비타민 B2"
       case .VITAMIN_B3:
           return "비타민 B3"
       case .VITAMIN_B5:
           return "비타민 B5"
       case .VITAMIN_B6:
           return "비타민 B6"
       case .VITAMIN_B7:
           return "비타민 B7"
       case .VITAMIN_B9:
           return "비타민 B9"
       case .VITAMIN_B12:
           return "비타민 B12"
       case .VITAMIN_C:
           return "비타민 C"
       case .VITAMIN_D:
           return "비타민 D"
       case .VITAMIN_E:
           return "비타민 E"
       case .VITAMIN_K:
           return "비타민 K"
       }
   }
   
   static func getNutritionUnit(_ nutritionType : NutrientEnums) -> String {
       switch nutritionType {
       case .CALRORIES:
           return "kcal"
       case .PROTEIN, .CARBOHYDRATES, .CARBOHYDRATES_DIETARY_FIBER,
            .CARBOHYDRATES_TOTAL_SUGAR, .CARBOHYDRATES_INCLUDE_ADDED_SUGAR,
            .FAT, .FAT_TRANS_FAT, .FAT_SATURATE_FAT:
           return "g"
       case .SODIUM, .CHOLESTEROL, .IRON, .CALCIUM, .POTASSIUM, .VITAMIN,
            .VITAMIN_B1, .VITAMIN_B2, .VITAMIN_B3, .VITAMIN_B5, .VITAMIN_B6, .VITAMIN_C, .VITAMIN_E:
           return "mg"
       case .VITAMIN_A, .VITAMIN_B7, .VITAMIN_B9, .VITAMIN_B12, .VITAMIN_D, .VITAMIN_K:
           return "µg"
       }
   }

    // 영양소별 최대값 설정 (프로그레스바 기준)
    static func getMaxValueForNutrition(_ nutritionType : NutrientEnums) -> Double {
        switch nutritionType {
        case .CALRORIES:
            return 2000.0 // 2000kcal
        case .PROTEIN:
            return 100.0  // 100g
        case .CARBOHYDRATES:
            return 300.0  // 300g
        case .CARBOHYDRATES_DIETARY_FIBER:
            return 25.0   // 25g
        case .CARBOHYDRATES_TOTAL_SUGAR, .CARBOHYDRATES_INCLUDE_ADDED_SUGAR:
            return 50.0   // 50g
        case .FAT:
            return 70.0   // 70g
        case .FAT_TRANS_FAT, .FAT_SATURATE_FAT:
            return 20.0   // 20g
        case .SODIUM:
            return 2300.0 // 2300mg
        case .CHOLESTEROL:
            return 300.0  // 300mg
        case .IRON:
            return 18.0   // 18mg
        case .CALCIUM:
            return 1200.0 // 1200mg
        case .POTASSIUM:
            return 3500.0 // 3500mg
        case .VITAMIN, .VITAMIN_C:
            return 100.0  // 100mg
        case .VITAMIN_B1, .VITAMIN_B2, .VITAMIN_B3, .VITAMIN_B5, .VITAMIN_B6, .VITAMIN_E:
            return 20.0   // 20mg
        case .VITAMIN_A, .VITAMIN_D:
            return 900.0  // 900µg
        case .VITAMIN_B7, .VITAMIN_B9, .VITAMIN_B12, .VITAMIN_K:
            return 100.0  // 100µg
        }
    }
   
    
}
