//
//  TabLayout.swift
//  FootHeart
//
//  Created by Jupond on 8/29/25.
//


import UIKit

class TabLayout: UIView {
    
    // MARK: - UI Components
    private lazy var tabHeader: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.register(TabHeaderCell.self, forCellWithReuseIdentifier: TabHeaderCell.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tabBody: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var tabList: [TabModel] = []
    private var controllerList: [UIViewController] = []
    private weak var parentVC: UIViewController?
    
    // Current selected tab index
    private var currentTabIndex: Int = 0
    
    // Indicator to track animation state
    private var isAnimating: Bool = false
    
    // 초기화 완료 플래그
    private var isSetupComplete: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(tabHeader)
        addSubview(tabBody)
        
        NSLayoutConstraint.activate([
            // Tab Header
            tabHeader.topAnchor.constraint(equalTo: topAnchor),
            tabHeader.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabHeader.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabHeader.heightAnchor.constraint(equalToConstant: 50),
            
            // Tab Body
            tabBody.topAnchor.constraint(equalTo: tabHeader.bottomAnchor),
            tabBody.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabBody.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabBody.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Setter Methods
    func setTabList(_ tabModelList: [TabModel]) {
        self.tabList = tabModelList
        tabHeader.reloadData()
        
        // 첫 번째 탭으로 초기화 (데이터가 준비된 후)
        checkAndInitialize()
    }
    
    func setControllers(_ vcList: [UIViewController]) {
        self.controllerList = vcList
        
        // 컨트롤러가 설정된 후 초기화 확인
        checkAndInitialize()
    }
    
    func setParentVC(_ vc: UIViewController) {
        self.parentVC = vc
        
        // 부모 VC가 설정된 후 초기화 확인
        checkAndInitialize()
    }
    
    // 모든 필수 데이터가 설정되었는지 확인하고 초기화
    private func checkAndInitialize() {
        guard !isSetupComplete,
              !tabList.isEmpty,
              !controllerList.isEmpty,
              parentVC != nil,
              tabList.count == controllerList.count else {
            return
        }
        
        isSetupComplete = true
        
        // 약간의 지연을 두어 UI가 완전히 렌더링된 후 초기화
        DispatchQueue.main.async { [weak self] in
            self?.initializeFirstTab()
        }
    }
    
    private func initializeFirstTab() {
        currentTabIndex = 0
        changeTabBody(to: currentTabIndex)
        
        // 첫 번째 탭 선택 상태로 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.selectTab(at: 0, animated: false)
        }
        
        print("✅ TabLayout: 초기화 완료")
    }
    
    // MARK: - Tab Management
    func selectTab(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < tabList.count && !isAnimating else {
            print("⚠️ TabLayout: 잘못된 탭 인덱스 \(index) 또는 애니메이션 진행 중")
            return
        }
        
        let previousIndex = currentTabIndex
        currentTabIndex = index
        
        // 컬렉션 뷰에서 탭 선택
        tabHeader.selectItem(at: IndexPath(item: index, section: 0),
                           animated: animated,
                           scrollPosition: .centeredHorizontally)
        
        // 탭 바디 변경
        changeTabBody(to: index)
        
        // 언더라인 애니메이션
        updateTabIndicators(from: previousIndex, to: index, animated: animated)
        
        print("✅ TabLayout: 탭 \(index) 선택됨")
    }
    
    private func updateTabIndicators(from previousIndex: Int, to currentIndex: Int, animated: Bool) {
        // 이전 탭의 언더라인 제거
        if previousIndex != currentIndex,
           let previousCell = tabHeader.cellForItem(at: IndexPath(item: previousIndex, section: 0)) as? TabHeaderCell {
            if animated {
                UIView.animate(withDuration: 0.2) {
                    previousCell.setUnderlineVisible(false)
                }
            } else {
                previousCell.setUnderlineVisible(false)
            }
        }
        
        // 현재 탭의 언더라인 표시
        if let currentCell = tabHeader.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? TabHeaderCell {
            if animated {
                isAnimating = true
                UIView.animate(withDuration: 0.3, animations: {
                    currentCell.setUnderlineVisible(true)
                }) { [weak self] _ in
                    self?.isAnimating = false
                }
            } else {
                currentCell.setUnderlineVisible(true)
            }
        }
    }
    
    private func changeTabBody(to index: Int) {
        guard index >= 0 && index < controllerList.count else {
            print("⚠️ TabLayout: 잘못된 컨트롤러 인덱스 \(index)")
            return
        }
        
        // 모든 자식 컨트롤러 제거
        removeAllChildControllers()
        
        // 새 컨트롤러 추가
        let targetController = controllerList[index]
        addChildController(targetController)
        
        print("✅ TabLayout: 탭 바디를 인덱스 \(index)로 변경")
    }
    
    private func removeAllChildControllers() {
        // 모든 서브뷰의 제약 조건을 명시적으로 제거
        tabBody.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        parentVC?.children.forEach { child in
            if controllerList.contains(child) {
                child.willMove(toParent: nil)
                child.removeFromParent()
            }
        }
    }
    
    private func addChildController(_ controller: UIViewController) {
        guard let parentVC = parentVC else {
            print("⚠️ TabLayout: parentVC가 설정되지 않았습니다")
            return
        }
        
        parentVC.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        tabBody.addSubview(controller.view)
        
        // 기존 제약 조건들을 비활성화하고 새로 설정
        controller.view.removeFromSuperview()
        tabBody.addSubview(controller.view)
        
        // 우선순위를 조정한 제약 조건 설정
        let topConstraint = controller.view.topAnchor.constraint(equalTo: tabBody.topAnchor)
        let leadingConstraint = controller.view.leadingAnchor.constraint(equalTo: tabBody.leadingAnchor)
        let trailingConstraint = controller.view.trailingAnchor.constraint(equalTo: tabBody.trailingAnchor)
        let bottomConstraint = controller.view.bottomAnchor.constraint(equalTo: tabBody.bottomAnchor)
        
        // 하단 제약 조건의 우선순위를 낮춤
        bottomConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint
        ])
        
        controller.didMove(toParent: parentVC)
    }
    // MARK: - Public Methods
    func getCurrentTabIndex() -> Int {
        return currentTabIndex
    }
    
    func getViewController(at index: Int) -> UIViewController? {
        guard index >= 0 && index < controllerList.count else { return nil }
        return controllerList[index]
    }
    
    func getCurrentViewController() -> UIViewController? {
        return getViewController(at: currentTabIndex)
    }
    
    func updateTabList(_ newTabList: [TabModel]) {
        self.tabList = newTabList
        tabHeader.reloadData()
    }
    
    // 수동으로 초기화 (필요한 경우)
    func manualInitialize() {
        guard !isSetupComplete else { return }
        checkAndInitialize()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension TabLayout: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabHeaderCell.identifier, for: indexPath) as? TabHeaderCell else {
            fatalError("TabHeaderCell을 등록하지 않았거나 타입이 맞지 않습니다")
        }
        
        let model = tabList[indexPath.item]
        cell.bind(model: model)
        
        // 현재 선택된 탭의 언더라인 상태 설정
        cell.setUnderlineVisible(indexPath.item == currentTabIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard tabList.count > 0 else { return CGSize(width: 0, height: 50) }
        let cellWidth = collectionView.bounds.width / CGFloat(tabList.count)
        return CGSize(width: cellWidth, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectTab(at: indexPath.item, animated: true)
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
    }
}

// MARK: - TabHeaderCell Extension
extension TabHeaderCell {
    static let identifier = "TabHeaderCell"
    
    func setUnderlineVisible(_ visible: Bool) {
        getLabelUnderline().backgroundColor = visible ? .label : .clear // 다크모드 자동 대응
    }
}
