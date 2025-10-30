//
//  DishModel.swift
//  FootHeart
//
//  Created by Jupond on 9/4/25.
//
import Foundation

struct DishModel {
    var uid : String
    var name : String
    var imageURL : String
    var nutrients : [NutrientModel]
    var ingredients : [IngredientModel]
    var eatenTime : Date
    var mealPattern : MealPatternType
}


