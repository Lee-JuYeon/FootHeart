//
//  NutritionViewController.swift
//  FootHeart
//
//  Created by Jupond on 6/10/25.
//

import UIKit

/*
 1. 인종별 섭취량 맥시멈 계산
 2. 음식 추가 액션시트 표시
 3. 요리사진 ai 경우의수
    1) 내가 요리한 경우
    2) 남이 요리한 경우 (받거나, 사거나)
    3) 밀키트를 산 경우 -> 영양선분표 찍기
    4) 밀키트에 내가 추가로 조리한 경우
 */

class NutritionViewController : UIViewController {
    
    // 위험알림 뷰
    private let dangerAlertView : DangerAlertView = {
        let view = DangerAlertView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 성분 필터링 뷰 -> actibvity이동하여 자세한 섭취성분표 -> fitler버튼 구현 ( 나트륨만 보기, 칼륨만 보기)
    
    // 약물 복용 -> 음식과 상호작용 ( 특정 음식 복용 금지)
    private let pillsView : PillsView = {
       let view = PillsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 수분 기록 + 혈압, 체중, 부종, 혈당 (토글버튼으로 그래프 교체)
    private let chartView :ToggleChartView = {
        let view = ToggleChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 총 섭취한 칼로리
    private let kcalProgressBar : NutritionProgressBar = {
        let view = NutritionProgressBar()
        view.setNutrientType(.CALRORIES)
        view.setConsumeGram(50.0)
        view.updateConsumeGram(1000.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 총 섭취한 탄단지(MACROS)
    private let macrosView : MacrosView = {
        let view = MacrosView()
        view.updateMacrosData(carbo: 400.0, protein: 100.0, fat: 20.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // water
    private let waterProgressBar : WaterCheckView = {
        let view = WaterCheckView()
        view.setDailyRecommendedIntake(2000) // 2L
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    // 영양성분표 사진찍기 -> 알레르기, 피해야할음식
    // 밀키트 상점
    // 냉장고 버튼 -> 메인, 디저트 요리 / 냉장고 남은 음식으로 요리,
    
    // 내가 섭취한 음식
    // 내가 즐쳐찾는 음식
    private let tabLayout: TabLayout = {
        let view = TabLayout()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(dangerAlertView)
        view.addSubview(pillsView)
        //        view.addSubview(kcalProgressBar)
        //        view.addSubview(macrosView)
        //        view.addSubview(chartView)
        
        view.addSubview(waterProgressBar)
        view.addSubview(tabLayout)
        
        setupWaterProgressView()
        setupTabLayout()
        setupDangerAlertView()
        setupPillsView()
       
        NSLayoutConstraint.activate([
            // 위험 알림 뷰
            dangerAlertView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            dangerAlertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dangerAlertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dangerAlertView.heightAnchor.constraint(equalToConstant: 50), // 높이 추가


            
            waterProgressBar.topAnchor.constraint(equalTo: dangerAlertView.bottomAnchor, constant: 0),
            waterProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            waterProgressBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5), // ✅ 화면 너비의 절반
            
            pillsView.topAnchor.constraint(equalTo: dangerAlertView.bottomAnchor, constant: 0),
            pillsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5), // ✅ 화면 너비의 절반
//            pillsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pillsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pillsView.heightAnchor.constraint(equalToConstant: 180), // greaterThanOrEqualTo 대신 고정 높이

            //            // 칼로리 - 맨 위에 위치
            //            kcalProgressBar.topAnchor.constraint(equalTo: dangerAlertView.bottomAnchor, constant: 30),
            //            kcalProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            //            kcalProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            //
            //            // 탄수화물 - 왼쪽 절반
            //            macrosView.topAnchor.constraint(equalTo: kcalProgressBar.bottomAnchor, constant: 20),
            //            macrosView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            //            macrosView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: 0),
            //
            //            // 차트뷰 - 오른쪽 절반
            //            chartView.topAnchor.constraint(equalTo: kcalProgressBar.bottomAnchor, constant: 20),
            //            chartView.leadingAnchor.constraint(equalTo: macrosView.trailingAnchor, constant: 0),
            //            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            //            chartView.heightAnchor.constraint(equalToConstant: 200), // 높이 추가
            
            tabLayout.topAnchor.constraint(equalTo: pillsView.bottomAnchor),
            tabLayout.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabLayout.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabLayout.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
      
    }
    
    private func setupWaterProgressView(){
        waterProgressBar.onViewTapped = { [weak self] in
            guard let self = self else { return }

            // 물방울 뷰가 클릭됨
            self.waterProgressBar.addWaterIntake(250) // 250ml 추가
        }
    }

    private func setupDangerAlertView(){

        dangerAlertView.setTitle("불빛만이 가득한 이 밤")
        dangerAlertView.onDangerAlertTapped = { [weak self] in
            let dangerBottomSheetVC = CustomBottomSheetView()
            /*
             .overFullScreen : 새 VC가 기존 화면을 완전히 덮음
             뒤에 있는 VC가 메모리에서 완전히 제거되지 않음 (화면만 가려짐)
             
             .fullScreen : 뒤 화면을 메모리에서 제거
             .pageSheet : iOS 13+에서 카드 형태로 표시 (전체화면 아님)
             */
            dangerBottomSheetVC.modalPresentationStyle = .overFullScreen
            
            /*
             화면 전환 애니메이션 방식:
             .crossDissolve : 페이드 인/아웃 효과 (서서히 나타나고 사라짐)
             부드럽고 자연스러운 전환 효과
             .coverVertical : 아래에서 위로 슬라이드 (기본값)
             .filHorizontal : 수평 뒤집기 효과
             .particalCurl : 페이지 넘기는 효과
             */
            dangerBottomSheetVC.modalTransitionStyle = .crossDissolve
            
            // 비동기로 컨텐츠 설정
            dangerBottomSheetVC.setContentView = { [weak self] contentView in
                self?.setupBottomSheetContent(in: contentView, dismissMethod: {
                    dangerBottomSheetVC.sheetDismiss()
                })
                
            }
                       
            
            self?.present(dangerBottomSheetVC, animated: false)
        }
    }
    
    private func setupBottomSheetContent(in contentView: UIView, dismissMethod: @escaping () -> Void) {
            let titleLabel: UILabel = {
                let label = UILabel()
                label.text = "⚠️ 위험 알림"
                label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                label.textColor = .systemRed
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
              
            let descriptionLabel: UILabel = {
                let label = UILabel()
                label.text = """
                현재 위험 상황이 감지되었습니다.
                
                • 주변 환경을 확인하세요
                • 안전한 장소로 이동하세요
                • 필요시 응급상황에 대비하세요
                """
                label.font = UIFont.systemFont(ofSize: 16)
                label.textColor = .secondaryLabel
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            
            let confirmButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("확인", for: .normal)
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.cornerRadius = 12
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            
            // contentView에 추가
            contentView.addSubview(titleLabel)
            contentView.addSubview(descriptionLabel)
            contentView.addSubview(confirmButton)
            
            // 제약조건 설정
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                confirmButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
                confirmButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                confirmButton.widthAnchor.constraint(equalToConstant: 100),
                confirmButton.heightAnchor.constraint(equalToConstant: 44),
                confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
            
            confirmButton.addAction(UIAction { _ in
                dismissMethod()
            }, for: .touchUpInside)
        }
    
    private func setupPillsView(){
        pillsView.setPillData([
            PillModel(id: "1", name: "타이레놀", doseDate: Date()),
            PillModel(id: "2", name: "애드빌", doseDate: Date()),
            PillModel(id: "3", name: "아스피린", doseDate: Date()),
            PillModel(id: "4", name: "비타민 C", doseDate: Date()),
            PillModel(id: "5", name: "오메가3", doseDate: Date())
        ])
        
    }
    
    // 탭 레이아웃 설정
    private let eatenVC : EatenViewController = EatenViewController()
    private let favouriteVC : FavouriteViewController = FavouriteViewController()
    private let fridgeVC : FridgeViewController = FridgeViewController()
    private let mealKitVC : MealKitViewController = MealKitViewController()
    private func setupTabLayout() {
        let controllerList: [UIViewController] = [
            eatenVC,
            favouriteVC,
            fridgeVC,
            mealKitVC
        ]
        
        tabLayout.setTabList([
            TabModel(title: "먹은 음식"),
            TabModel(title: "즐겨찾기"),
            TabModel(title: "밀키트"),
            TabModel(title: "나의 냉장고")
        ])
        tabLayout.setControllers(controllerList)
        tabLayout.setParentVC(self)

        
    }

}
