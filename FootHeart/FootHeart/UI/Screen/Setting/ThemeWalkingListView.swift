//
//  ThemeListView.swift
//  FootHeart
//
//  Created by Jupond on 6/12/25.
//

import UIKit


class ThemeWalkingListView: UIView {
    
    
       // MARK: - Properties
       var themeList: [ThemeWalkingModel] = []
       
       var onItemClick: ((ThemeWalkingModel, Int) -> Void)?
       var onHeaderClick: (() -> Void)?
       var onLoadMore: ((Int) -> Void)?
       
       // Pagination 상태
       private var currentPage: Int = 0
       private var isLoading: Bool = false
       private var hasMoreData: Bool = true
       
       // MARK: - UI Components
       private let collectionView: UICollectionView = {
           let layout = HorizontalFixedHeaderLayout() // 커스텀 레이아웃
           let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
           cv.showsHorizontalScrollIndicator = false
           cv.showsVerticalScrollIndicator = false
           cv.alwaysBounceVertical = false        // 수직 바운스 비활성화
           cv.alwaysBounceHorizontal = true       // 수평 바운스만 유지
           cv.contentInsetAdjustmentBehavior = .never  // 자동 인셋 조정 방지
           cv.backgroundColor = .clear
           cv.translatesAutoresizingMaskIntoConstraints = false
           return cv
       }()
       
       private let loadingIndicator: UIActivityIndicatorView = {
           let indicator = UIActivityIndicatorView(style: .medium)
           indicator.hidesWhenStopped = true
           indicator.translatesAutoresizingMaskIntoConstraints = false
           return indicator
       }()
       
       private let refreshControl: UIRefreshControl = {
           let refreshControl = UIRefreshControl()
           refreshControl.tintColor = .systemBlue
           return refreshControl
       }()
       
       private let emptyStateView: UIView = {
           let view = UIView()
           view.translatesAutoresizingMaskIntoConstraints = false
           view.isHidden = true
           return view
       }()
       
       private let emptyStateLabel: UILabel = {
           let label = UILabel()
           label.text = "테마가 없습니다.\n새로운 테마를 추가해보세요!"
           label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
           label.textColor = .secondaryLabel
           label.textAlignment = .center
           label.numberOfLines = 0
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()
       
       // MARK: - Initialization
       override init(frame: CGRect) {
           super.init(frame: frame)
           setupUI()
           setupActions()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           setupUI()
           setupActions()
       }
       
       // MARK: - UI Setup
       private func setupUI() {
           self.addSubview(collectionView)
           self.addSubview(loadingIndicator)
           self.addSubview(emptyStateView)
           
           emptyStateView.addSubview(emptyStateLabel)
           collectionView.refreshControl = refreshControl
           
           // CollectionView 설정
           collectionView.delegate = self
           collectionView.dataSource = self
           
           // 셀과 헤더 등록
           collectionView.register(ThemeWalkingCell.self, forCellWithReuseIdentifier: ThemeWalkingCell.identifier)
           collectionView.register(ThemeWalkingHeaderView.self,
                                  forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                  withReuseIdentifier: ThemeWalkingHeaderView.identifier)
           
           NSLayoutConstraint.activate([
               // Collection View
               collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
               collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
               collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
               collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
               
               // Loading Indicator
               loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
               loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
               
               // Empty State View
               emptyStateView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
               emptyStateView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
               emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor, constant: 20),
               emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: collectionView.trailingAnchor, constant: -20),
               
               // Empty State Label
               emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
               emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
               emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
               emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
           ])
       }
       
       private func setupActions() {
           refreshControl.addTarget(self, action: #selector(refreshThemeWalkingList), for: .valueChanged)
       }
       
       @objc private func refreshThemeWalkingList() {
           currentPage = 0
           themeList.removeAll()
           hasMoreData = true
           onLoadMore?(0)
       }
       
       // MARK: - Public Methods
       func updateThemeList(_ themes: [ThemeWalkingModel], isRefresh: Bool = false) {
           if isRefresh {
               themeList = themes
               currentPage = 1
           } else {
               themeList.append(contentsOf: themes)
               currentPage += 1
           }
           
           hasMoreData = themes.count >= 6
           isLoading = false
           
           DispatchQueue.main.async {
               self.refreshControl.endRefreshing()
               self.loadingIndicator.stopAnimating()
               self.collectionView.reloadData()
               self.updateEmptyState()
           }
       }
       
       func showLoading() {
           isLoading = true
           DispatchQueue.main.async {
               if self.themeList.isEmpty {
                   self.loadingIndicator.startAnimating()
                   self.emptyStateView.isHidden = true
               }
           }
       }
       
       func showError(_ message: String) {
           isLoading = false
           DispatchQueue.main.async {
               self.refreshControl.endRefreshing()
               self.loadingIndicator.stopAnimating()
               self.updateEmptyState()
               print("Error: \(message)")
           }
       }
       
       func updateHasMoreData(_ hasMore: Bool) {
           hasMoreData = hasMore
       }
       
       func initThemeWalkingList() {
           showLoading()
           onLoadMore?(0)
       }
       
       private func updateEmptyState() {
           let isEmpty = themeList.isEmpty && !isLoading
           emptyStateView.isHidden = !isEmpty
           collectionView.isHidden = isEmpty
       }
   }

   // MARK: - 수평 스크롤 + 고정 헤더 레이아웃
   class HorizontalFixedHeaderLayout: UICollectionViewLayout {
       
       private var itemAttributes: [UICollectionViewLayoutAttributes] = []
       private var headerAttributes: UICollectionViewLayoutAttributes?
       
       // 레이아웃 설정값
       private let itemWidth: CGFloat = 180
       private let itemHeight: CGFloat = 220
       private let headerWidth: CGFloat = 100
       private let itemSpacing: CGFloat = 12
       private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       
       override var collectionViewContentSize: CGSize {
           guard let collectionView = collectionView else { return .zero }
           
           let numberOfItems = collectionView.numberOfItems(inSection: 0)
           
           // 헤더 폭 + 아이템들 폭 + 간격들 + 여백
           let contentWidth = headerWidth + (itemWidth + itemSpacing) * CGFloat(numberOfItems) + sectionInsets.left + sectionInsets.right
           let contentHeight = collectionView.bounds.height
           
           return CGSize(width: contentWidth, height: contentHeight)
       }
       
       override func prepare() {
           super.prepare()
           
           guard let collectionView = collectionView else { return }
           
           itemAttributes.removeAll()
           
           let numberOfItems = collectionView.numberOfItems(inSection: 0)
           
           // 1. 헤더 레이아웃 계산 (왼쪽 고정)
           let headerIndexPath = IndexPath(item: 0, section: 0)
           headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
           
           // 헤더를 스크롤 위치에 관계없이 왼쪽에 고정
           let headerX = collectionView.contentOffset.x + sectionInsets.left
           let headerFrame = CGRect(
               x: headerX,
               y: sectionInsets.top,
               width: headerWidth,
               height: itemHeight
           )
           headerAttributes?.frame = headerFrame
           headerAttributes?.zIndex = 1000 // 다른 요소들 위에 표시
           
           // 2. 아이템들 레이아웃 계산 (수평 배치)
           var currentX = sectionInsets.left + headerWidth + itemSpacing
           
           for item in 0..<numberOfItems {
               let indexPath = IndexPath(item: item, section: 0)
               let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
               
               let frame = CGRect(
                   x: currentX,
                   y: sectionInsets.top,
                   width: itemWidth,
                   height: itemHeight
               )
               
               attributes.frame = frame
               itemAttributes.append(attributes)
               
               currentX += itemWidth + itemSpacing
           }
       }
       
       override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
           var visibleAttributes: [UICollectionViewLayoutAttributes] = []
           
           // 헤더는 항상 표시 (고정)
           if let headerAttributes = headerAttributes {
               visibleAttributes.append(headerAttributes)
           }
           
           // 보이는 영역의 아이템들만 추가
           for attributes in itemAttributes {
               if attributes.frame.intersects(rect) {
                   visibleAttributes.append(attributes)
               }
           }
           
           return visibleAttributes
       }
       
       override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
           return itemAttributes[safe: indexPath.item]
       }
       
       override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
           if elementKind == UICollectionView.elementKindSectionHeader {
               return headerAttributes
           }
           return nil
       }
       
       override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
           // 스크롤할 때마다 헤더 위치 업데이트 (고정 효과)
           return true
       }
   }

   // MARK: - Array Safe Extension
   extension Array {
       subscript(safe index: Int) -> Element? {
           return indices.contains(index) ? self[index] : nil
       }
   }

   // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
   extension ThemeWalkingListView: UICollectionViewDataSource, UICollectionViewDelegate {
       
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return themeList.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           guard indexPath.section == 0 else {
               print("⚠️ cellForItemAt: Invalid section \(indexPath.section)")
               return UICollectionViewCell()
           }
           
           // 안전한 인덱스 체크
           guard indexPath.item >= 0 && indexPath.item < themeList.count else {
               print("⚠️ cellForItemAt: Index out of range - indexPath.item(\(indexPath.item)) not in range 0..<\(themeList.count)")
               // 빈 셀 반환
               let emptyCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeWalkingCell.identifier, for: indexPath)
               return emptyCell
           }
           
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeWalkingCell.identifier, for: indexPath) as? ThemeWalkingCell else {
               return UICollectionViewCell()
           }
           
           let theme = themeList[indexPath.item]
           cell.configure(with: theme)
           
           // 좋아요 버튼 액션 설정
//           cell.onLikeButtonTapped = { [weak self] themeUID in
//               self?.handleLikeButtonTapped(themeUID: themeUID, at: indexPath)
//           }
           
           return cell
       }
       
       // 📌 Header View (UICollectionReusableView)
       func collectionView(_ collectionView: UICollectionView,
                           viewForSupplementaryElementOfKind kind: String,
                           at indexPath: IndexPath) -> UICollectionReusableView {
           if kind == UICollectionView.elementKindSectionHeader {
               guard let headerView = collectionView.dequeueReusableSupplementaryView(
                   ofKind: kind,
                   withReuseIdentifier: ThemeWalkingHeaderView.identifier,
                   for: indexPath
               ) as? ThemeWalkingHeaderView else {
                   return UICollectionReusableView()
               }
               
               headerView.addThemeAction = { [weak self] in
                   self?.onHeaderClick?()
               }
               
               return headerView
           }
           
           return UICollectionReusableView()
       }
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
           guard indexPath.item < themeList.count else {
                      print("⚠️ didSelectItemAt: indexPath.item(\(indexPath.item)) >= themeList.count(\(themeList.count))")
                      return
                  }
           let theme = themeList[indexPath.item]
           
           // 햅틱 피드백
           let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
           impactGenerator.impactOccurred()
           
           // 아이템 클릭 이벤트 전달
           onItemClick?(theme, indexPath.item)
       }
       
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
           // 수평 스크롤에서 페이지네이션 처리
           let offsetX = scrollView.contentOffset.x
           let contentWidth = scrollView.contentSize.width
           let width = scrollView.frame.size.width
           
           // 오른쪽 끝에 가까워지면 더 로드
           if offsetX > contentWidth - width - 100 {
               if hasMoreData && !isLoading {
                   showLoading()
                   onLoadMore?(currentPage)
               }
           }
       }
       
       // MARK: - Private Methods
       private func handleLikeButtonTapped(themeUID: String, at indexPath: IndexPath) {
           print("좋아요 버튼 클릭: \(themeUID)")
           
           guard indexPath.item < themeList.count else { return }
           
           let currentUserUID = "current_user_uid"
           
           if themeList[indexPath.item].liked.contains(currentUserUID) {
               themeList[indexPath.item].liked.removeAll { $0 == currentUserUID }
           } else {
               themeList[indexPath.item].liked.append(currentUserUID)
           }
           
           DispatchQueue.main.async {
               self.collectionView.reloadItems(at: [indexPath])
           }
       }
   }
