//
//  MainTabBarController.swift
//  FootHeart
//
//  Created by Jupond on 6/10/25.
//
import UIKit

class MainTabBarController : UITabBarController {
    
    // MARK: - Properties
    private let walkingVM: WalkingVM
    private let walkingRepository: WalkingRepository
    private let themeWalkingRepository: ThemeWalkingRepository
    
    // MARK: - Initialization
    init() {
        // 1. 먼저 의존성들을 초기화
        self.walkingRepository = WalkingRepository()
        self.themeWalkingRepository = ThemeWalkingRepository()
        
        // 2. WalkingVM 초기화 (ObservableObject 사용)
        self.walkingVM = WalkingVM(
            repository: walkingRepository,
            themeWalkingRepository: themeWalkingRepository
        )
        
        // 3. super.init 호출
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    
  
    private func setupDelegate() {
        self.delegate = self
    }
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        setupTabs()
        setupTabBarAppearance()
        
    }
    
    private func setupTabs(){
        // 만보기 +걷기 , 테마걷기 ,오디오 걷기, 러너스 하이, 영양측정
        /*
         - 만보기 + 걷기
         - 영약측정
         - 테마별 걷기 ( 오디오 게임 걷기, 러너스 하이, 유저참여)
         - 오디오 가이드 + 러너스 하이 + 걷는 중 내 몸 발랜스 ( 옵션으로 설정)
         */
        let walkingVC = WalkingViewController()
        let walkingNav = UINavigationController(rootViewController: walkingVC)
        walkingNav.tabBarItem = UITabBarItem(
            title : "걷기",
            image: UIImage(systemName: "figure.walk"),
            selectedImage: UIImage(systemName: "figure.walk.circle.fill")
        )
        walkingNav.tabBarItem.tag = 0
        
        let themeWalkingVC = ThemeWalkingViewController(walkingVM: walkingVM)
        let themeWalkingNav = UINavigationController(rootViewController: themeWalkingVC)
        themeWalkingNav.tabBarItem = UITabBarItem(
            title : "테마별 걷기",
            image: UIImage(systemName: "figure.walk"),
            selectedImage: UIImage(systemName: "figure.walk.circle.fill")
        )
        themeWalkingNav.tabBarItem.tag = 1
        
        let nutritionVC = NutritionViewController()
        let nutritionNav = UINavigationController(rootViewController: nutritionVC)
        nutritionNav.tabBarItem = UITabBarItem(
            title : "영양 섭취",
            image: UIImage(systemName: "figure.walk"),
            selectedImage: UIImage(systemName: "figure.walk.circle.fill")
        )
        nutritionNav.tabBarItem.tag = 2

        // 탭들을 TabBarController에 설정
        viewControllers = [walkingNav, themeWalkingNav, nutritionNav]
             
        // 기본 선택 탭 설정
        selectedIndex = 0
    }
    
    private func setupTabBarAppearance() {
          // iOS 15+ 스타일 적용
          if #available(iOS 15.0, *) {
              let appearance = UITabBarAppearance()
              appearance.configureWithOpaqueBackground()
              appearance.backgroundColor = .systemBackground
              appearance.shadowColor = .separator
              
              // 선택되지 않은 탭 아이템 색상
              appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
              appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                  .foregroundColor: UIColor.systemGray
              ]
              
              // 선택된 탭 아이템 색상
              appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
              appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                  .foregroundColor: UIColor.systemBlue
              ]
              tabBar.standardAppearance = appearance
              tabBar.scrollEdgeAppearance = appearance
          } else {
              // iOS 14 이하 호환성
              tabBar.backgroundColor = .systemBackground
              tabBar.tintColor = .systemBlue
              tabBar.unselectedItemTintColor = .systemGray
          }
          
          // 그림자 효과
          tabBar.layer.shadowColor = UIColor.black.cgColor
          tabBar.layer.shadowOpacity = 0.1
          tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
          tabBar.layer.shadowRadius = 4
      }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // 탭 선택 시 햅틱 피드백
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        
        // 선택된 탭에 따른 추가 동작 수행
        switch tabBarController.selectedIndex {
        case 0:
            print("걷기 탭 선택됨")
        case 1:
            print("테마별 걷기 탭 선택됨")
            // 테마 걷기 탭 선택시 데이터 로드 (필요한 경우)
            loadThemeWalkingDataIfNeeded()
        case 2:
            print("영양 섭취 탭 선택됨")
        default:
            break
        }
    }
    
    private func loadThemeWalkingDataIfNeeded() {
        // 테마 걷기 리스트가 비어있다면 로드
        if walkingVM.themeWalkingList.isEmpty {
            walkingVM.loadThemeWalkingList()
        }
    }
}
