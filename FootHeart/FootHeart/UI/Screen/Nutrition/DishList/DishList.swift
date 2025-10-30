//
//  DishList.swift
//  FootHeart
//
//  Created by Jupond on 9/4/25.
//

import UIKit

class DishList: UIView {
    
    weak var delegate: DishListDelegate?
    
    private var dishList: [DishModel] = []
    private var selectedDishIndex: Int?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 셀과 헤더 등록
        collectionView.register(DishCell.self, forCellWithReuseIdentifier: DishCell.identifier)
        collectionView.register(DishHeaderCell.self, forCellWithReuseIdentifier: DishHeaderCell.identifier)
    }
    
    // MARK: - Public Methods
    func updateDishList(_ dishes: [DishModel]) {
        self.dishList = dishes
        collectionView.reloadData()
    }
    
    func addDish(_ dish: DishModel) {
        dishList.append(dish)
        let indexPath = IndexPath(item: dishList.count, section: 0) // +1 because of header
        collectionView.insertItems(at: [indexPath])
    }
    
    func removeDish(at index: Int) {
        guard index >= 0 && index < dishList.count else { return }
        
        dishList.remove(at: index)
        let indexPath = IndexPath(item: index + 1, section: 0) // +1 because of header
        collectionView.deleteItems(at: [indexPath])
        
        // 선택된 인덱스 조정
        if let selectedIndex = selectedDishIndex {
            if selectedIndex == index {
                self.selectedDishIndex = nil
            } else if selectedIndex > index {
                self.selectedDishIndex = selectedIndex - 1
            }
        }
    }
    
    func selectDish(at index: Int) {
        guard index >= 0 && index < dishList.count else { return }
        
        selectedDishIndex = index
        let indexPath = IndexPath(item: index + 1, section: 0) // +1 because of header
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        collectionView.reloadData()
        
        let selectedDish = dishList[index]
        delegate?.onClick(self, didSelectDish: selectedDish, at: index)
    }
    
    func getSelectedDish() -> (dish: DishModel, index: Int)? {
        guard let selectedIndex = selectedDishIndex,
              selectedIndex < dishList.count else { return nil }
        
        return (dishList[selectedIndex], selectedIndex)
    }
    
    func getDishCount() -> Int {
        return dishList.count
    }
    
    func getDish(at index: Int) -> DishModel? {
        guard index >= 0 && index < dishList.count else { return nil }
        return dishList[index]
    }
    
    func clearSelection() {
        selectedDishIndex = nil
        collectionView.reloadData()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension DishList: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishList.count + 1 // +1 for header cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 첫 번째 셀은 헤더
        if indexPath.item == 0 {
            guard let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: DishHeaderCell.identifier, for: indexPath) as? DishHeaderCell else {
                return UICollectionViewCell()
            }
            
            headerCell.onAddButtonTapped = { [weak self] in
                guard let self = self else { return }
                self.delegate?.onAddClick(self)
            }
            
            return headerCell
        }
        
        // 나머지는 음식 셀
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DishCell.identifier, for: indexPath) as? DishCell else {
            return UICollectionViewCell()
        }
        
        let dishIndex = indexPath.item - 1 // -1 because of header
        let dish = dishList[dishIndex]
        cell.configure(with: dish)
        
        // 선택된 셀 표시
        if dishIndex == selectedDishIndex {
            cell.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            cell.layer.borderColor = UIColor.systemBlue.cgColor
            cell.layer.borderWidth = 2
        } else {
            cell.backgroundColor = .systemBackground
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
        }
        
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 4
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 헤더 셀 클릭은 무시
        guard indexPath.item > 0 else { return }
        
        let dishIndex = indexPath.item - 1 // -1 because of header
        selectedDishIndex = dishIndex
        let selectedDish = dishList[dishIndex]
        
        collectionView.reloadData() // 선택 상태 업데이트
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // 델리게이트에 선택 알림
        delegate?.onClick(self, didSelectDish: selectedDish, at: dishIndex)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DishList: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let insets = layout.sectionInset
        let spacing = layout.minimumInteritemSpacing
        
//        // 헤더 셀인 경우 - 전체 폭 사용
//        if indexPath.item == 0 {
//            let totalWidth = collectionView.bounds.width - insets.left - insets.right
//            return CGSize(width: totalWidth, height: 80)
//        }
//        
        // 일반 음식 셀인 경우 - 가로 2개씩
        let totalWidth = collectionView.bounds.width - insets.left - insets.right - spacing
        let itemWidth = totalWidth / 2
        let itemHeight: CGFloat = 140
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
