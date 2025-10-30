//
//  Untitled.swift
//  FootHeart
//
//  Created by Jupond on 8/30/25.
//

import UIKit

class PillsView : UIView {
    
    // 샘플 데이터
    private var pillData: [PillModel] = []
    func setPillData(_ list : [PillModel]){
        self.pillData = list
        listview.reloadData()   // ✅ 데이터 반영
    }
    
    private lazy var listview: UICollectionView = {
        let layout = createLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.showsHorizontalScrollIndicator = false
        
        // 셀 등록
        view.register(PillCell.self, forCellWithReuseIdentifier: PillCell.identifier)
        // 헤더 등록
        view.register(
            PillHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PillHeader.identifier
        )
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI(){
        self.addSubview(listview)
        
        NSLayoutConstraint.activate([
            listview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            listview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            listview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            listview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        ])
        
        setupListView()
    }
    
    private func setupListView(){
        listview.delegate = self
        listview.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            // 아이템 크기 조정 (높이 증가)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(80),
                heightDimension: .absolute(110) // 100 → 110으로 증가
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // 그룹 크기도 조정
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(80),
                heightDimension: .absolute(110) // 100 → 110으로 증가
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // 나머지는 동일...
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .absolute(80),
                heightDimension: .absolute(90)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .leading
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        return layout
    }
}

extension PillsView : UICollectionViewDataSource, UICollectionViewDelegate {
    
    // CollectionView에서 표시할 섹션의 개수를 결정
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 각 섹션에서 표시할 아이템(셀)의 개수를 결정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pillData.count
    }
        
    // 각 위치에 표시할 실제 셀을 생성하고 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // dequeueReusableCell: 메모리 효율을 위해 재사용 가능한 셀을 가져옴
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCell.identifier, for: indexPath) as? PillCell else {
            return UICollectionViewCell()
        }
        
        let pill = pillData[indexPath.item]
        cell.configure(topColour: .yellow, bottomColour: .blue, title: pill.name)

        return cell
    }
    
    // 헤더나 푸터 같은 보조 뷰를 생성합니다.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // elementKindSectionHeader: 섹션 헤더를 의미
        if kind == UICollectionView.elementKindSectionHeader {
            // dequeueReusableSupplementaryView: 재사용 가능한 보조 뷰를 가져옴
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PillHeader.identifier,
                for: indexPath
            ) as? PillHeader else {
                return UICollectionReusableView()
            }
            
            headerView.configure(title: "새 알약\n추가하기")
            
//            headerView.onHeaderTapped = { [weak self] in
//                self?.showAddPillAlert()
//            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    // 사용자가 셀을 터치했을 때의 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pill = pillData[indexPath.item]
        print("선택된 알약: \(pill.name)")
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
}
