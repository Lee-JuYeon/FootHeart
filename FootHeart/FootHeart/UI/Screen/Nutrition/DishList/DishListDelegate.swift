//
//  DishListDelegate.swift
//  FootHeart
//
//  Created by Jupond on 9/4/25.
//

protocol DishListDelegate: AnyObject {
    func onClick(_ dishList: DishList, didSelectDish dish: DishModel, at index: Int)
    func onAddClick(_ dishList: DishList)
    
}
