//
//  EatenViewController.swift
//  FootHeart
//
//  Created by Jupond on 8/30/25.
//

import UIKit

class EatenViewController : UIViewController {
    
   
    
    private let dishList: DishList = {  // UILabel로 타입 수정
        let view = DishList()  // UILabel로 변수명 수정
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 오른쪽 상세 뷰
    private let detailView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(dishList)
        view.addSubview(detailView)
        
   
        NSLayoutConstraint.activate([
            // TableView - 왼쪽 1/3
            dishList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dishList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dishList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dishList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        ])
        
        setupTableView()
    }
    
   
    private func setupTableView() {
        dishList.updateDishList(
            [
               DishModel(
                   uid: "1",
                   name: "김치찌개",
                   imageURL: "https://example.com/kimchi.jpg",
                   nutrients: [
                       NutrientModel(uid: "n1"),
                       NutrientModel(uid: "n2")
                   ],
                   ingredients: [
                       IngredientModel(uid: "i1"),
                       IngredientModel(uid: "i2")
                   ],
                   eatenTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 8, hour: 8, minute: 30))!,
                   mealPattern: MealPatternType.BREAKFAST
               ),
               DishModel(
                   uid: "2",
                   name: "불고기",
                   imageURL: "https://example.com/bulgogi.jpg",
                   nutrients: [
                       NutrientModel(uid: "n3"),
                       NutrientModel(uid: "n4")
                   ],
                   ingredients: [
                       IngredientModel(uid: "i3"),
                       IngredientModel(uid: "i4")
                   ],
                   eatenTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 7, hour: 8, minute: 30))!,
                   mealPattern: MealPatternType.LUNCH
               ),
               DishModel(
                   uid: "3",
                   name: "비빔밥",
                   imageURL: "https://example.com/bibimbap.jpg",
                   nutrients: [
                       NutrientModel(uid: "n5"),
                       NutrientModel(uid: "n6")
                   ],
                   ingredients: [
                       IngredientModel(uid: "i5"),
                       IngredientModel(uid: "i6")
                   ],
                   eatenTime: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 8, hour: 8, minute: 30))!,
                   mealPattern: MealPatternType.DINNER
               )
           ]
        )
        dishList.delegate = self
       
    }
}

extension EatenViewController : DishListDelegate {
    func onAddClick(_ dishList: DishList) {
        // 헤더 클릭 이벤트
    }
    func onClick(_ dishList: DishList, didSelectDish dish: DishModel, at index: Int) {
        // 셀 클릭 이벤트
    }
}
