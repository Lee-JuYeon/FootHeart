//
//  Untitled.swift
//  FootHeart
//
//  Created by Jupond on 6/10/25.
//

import UIKit
import Combine

class ThemeWalkingViewController : UIViewController {
    
   
    
    private let themeWalkingTitle : UILabel = {
        let view = UILabel()
        view.text = "테마별 걷기"
        view.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.textColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let themeWalkingList : ThemeWalkingListView = {
        let view = ThemeWalkingListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
 
    // MARK: - Properties
    private let walkingVM: WalkingVM
    private var cancellables = Set<AnyCancellable>()
        
    
    init(walkingVM: WalkingVM) {
        self.walkingVM = walkingVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setWalkingVM()
        setThemeWalkingListView()
        loadInitialData()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshThemeWalkingListIfNeeded()
    }
    
    
    private func setupUI(){
        view.backgroundColor = .systemBackground

        
        view.addSubview(themeWalkingTitle)
        view.addSubview(moreButton)
        view.addSubview(themeWalkingList)
        
        NSLayoutConstraint.activate([
            // Theme Walking Title
            themeWalkingTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            themeWalkingTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            
            // More Button
            moreButton.centerYAnchor.constraint(equalTo: themeWalkingTitle.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            moreButton.leadingAnchor.constraint(greaterThanOrEqualTo: themeWalkingTitle.trailingAnchor, constant: 0),
            
            // Theme List View
            themeWalkingList.topAnchor.constraint(equalTo: themeWalkingTitle.bottomAnchor, constant: 0),
            themeWalkingList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            themeWalkingList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            themeWalkingList.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            themeWalkingList.heightAnchor.constraint(greaterThanOrEqualToConstant: 12), // 최소 높이
            themeWalkingList.heightAnchor.constraint(lessThanOrEqualToConstant: 500)     // 최대 높이
        ])
        
        setupActions()

    }
    
    private func setupActions() {
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func moreButtonTapped() {
        navigateToAllThemesList()
    }
       
    
    private func setWalkingVM() {
        
        // 테마 리스트 변경 감지
        walkingVM.$themeWalkingList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] themes in
                self?.updateThemeList(themes)
            }
            .store(in: &cancellables)
        
        
        // 로딩 상태 변경 감지
        walkingVM.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // 에러 메시지 감지
        walkingVM.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // nil이 아닌 값만 전달
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
        
        // 더 많은 데이터 여부 감지
        walkingVM.$hasMoreData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasMoreData in
                self?.themeWalkingList.updateHasMoreData(hasMoreData)
            }
            .store(in: &cancellables)
        
        // 현재 걸음 모델 감지 (추가)
        walkingVM.$currentWalkingModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] walkingModel in
                self?.updateCurrentWalkingModel(walkingModel)
            }
            .store(in: &cancellables)
        
        // 현재 걸음 에러 메시지 감지 (추가)
        walkingVM.$currentWalkingErrorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showCurrentWalkingErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setThemeWalkingListView(){
        // 아이템 클릭 이벤트 처리
        themeWalkingList.onItemClick = { [weak self] theme, index in
            self?.onClickThemeItem(theme: theme, index: index)
        }
        
        // 헤더 버튼(테마 추가) 클릭 이벤트 처리
        themeWalkingList.onHeaderClick = { [weak self] in
            self?.onClickAddTheme()
        }
        
        // 페이지네이션 로드 이벤트 처리
        themeWalkingList.onLoadMore = { [weak self] page in
            self?.loadThemeWalkingData(page: page)
        }
    }
    
    private func loadInitialData() {
        // 현재 걸음 수 로드
        walkingVM.loadCurrentWalkingModel()
        
        // 테마 걷기 리스트 초기 로드
        loadInitialThemeWalkingList()
    }
    
    // MARK: - Data Loading
    private func loadInitialThemeWalkingList() {
        walkingVM.loadThemeWalkingList()
    }
    
    private func loadThemeWalkingData(page: Int) {
        if page == 0 {
            // 첫 페이지 또는 새로고침
            walkingVM.refreshThemeWalkingList()
        } else {
            // 페이지네이션
            walkingVM.pagenation(currentPageIndex: page - 1, nextPageIndex: page)
        }
    }
       
    
    private func refreshThemeWalkingListIfNeeded() {
        // 리스트가 비어있으면 다시 로드
        if walkingVM.themeWalkingList.isEmpty {
            loadInitialThemeWalkingList()
        }
    }
    
    private func updateThemeList(_ themes: [ThemeWalkingModel]) {
        // 새로고침인지 페이지네이션인지 판단
        let isRefresh = themes.count <= walkingVM.pageSize || walkingVM.themeWalkingList.count <= walkingVM.pageSize
        themeWalkingList.updateThemeList(themes, isRefresh: isRefresh)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            themeWalkingList.showLoading()
        }
        // 로딩 종료는 updateThemeList에서 자동 처리
    }
    
    private func updateCurrentWalkingModel(_ walkingModel: CurrentWalkingModel?) {
        guard let walkingModel = walkingModel else { return }
        print("현재 걸음 수 업데이트: \(walkingModel)")
        // TODO: 필요시 UI에 현재 걸음 수 표시
    }
    
    // MARK: - Event Handlers
    private func onClickThemeItem(theme: ThemeWalkingModel, index: Int) {
        if theme.isLocked {
            showLockedThemeAlert(theme: theme)
        } else {
            navigateToThemeDetail(theme: theme)
        }
    }
    
    private func onClickAddTheme() {
        presentAddThemeScreen()
    }
    
    // MARK: - Navigation Methods
    private func navigateToThemeDetail(theme: ThemeWalkingModel) {
        print("테마 상세 화면으로 이동: \(theme.themeTitle)")
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        // TODO: 테마 상세 뷰컨트롤러로 이동
        // let detailVC = ThemeDetailViewController(theme: theme, walkingVM: walkingVM)
        // navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func navigateToAllThemesList() {
        print("전체 테마 리스트 화면으로 이동")
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // TODO: 전체 테마 리스트 뷰컨트롤러로 이동
        // let allThemesVC = AllThemesViewController(walkingVM: walkingVM)
        // navigationController?.pushViewController(allThemesVC, animated: true)
    }
    
    private func presentAddThemeScreen() {
        print("테마 추가 화면 표시")
        
        // 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
        
        // TODO: 테마 추가 화면 모달 표시
        // let addThemeVC = AddThemeViewController()
        // addThemeVC.delegate = self
        // addThemeVC.walkingVM = walkingVM
        // let navController = UINavigationController(rootViewController: addThemeVC)
        // present(navController, animated: true)
    }
    
    // MARK: - Alert Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            // 에러 메시지 클리어
            self?.walkingVM.clearErrorMessage()
        })
        
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { [weak self] _ in
            // 에러 메시지 클리어 후 재시도
            self?.walkingVM.clearErrorMessage()
            self?.walkingVM.refreshThemeWalkingList()
        })
        
        present(alert, animated: true)
    }
    
    private func showCurrentWalkingErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "걸음 수 로드 오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.walkingVM.clearErrorMessage()
        })
        
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { [weak self] _ in
            self?.walkingVM.clearErrorMessage()
            self?.walkingVM.loadCurrentWalkingModel()
        })
        
        present(alert, animated: true)
    }
    
    private func showLockedThemeAlert(theme: ThemeWalkingModel) {
        let alert = UIAlertController(
            title: "잠긴 테마",
            message: "\(theme.themeTitle)은(는) 잠긴 테마입니다.\n특정 조건을 만족하면 해제됩니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        alert.addAction(UIAlertAction(title: "조건 확인", style: .default) { _ in
            print("잠금 해제 조건 화면으로 이동")
            // TODO: 잠금 해제 조건 화면으로 이동
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Public Methods (외부에서 호출 가능)
    
    /// 새로운 테마 추가
    func addNewTheme(_ theme: ThemeWalkingModel) {
        walkingVM.addTheme(theme)
    }
       
    
    /// 수동 새로고침
    func refreshThemeList() {
        walkingVM.refreshThemeWalkingList()
    }
    
    /// 상태 초기화
    func resetState() {
        walkingVM.resetState()
    }
    
    // MARK: - Memory Management
    deinit {
        cancellables.removeAll()
        print("ThemeWalkingViewController 메모리 해제")
    }

      
}
