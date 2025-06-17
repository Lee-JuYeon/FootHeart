//
//  WalkingVM.swift
//  FootHeart
//
//  Created by Jupond on 5/21/25.
//
import Combine
import CoreLocation

class WalkingVM : ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let walkingRepository : WalkingRepository
    private let themeWalkingRepository: ThemeWalkingProtocol
    
    init(
        repository : WalkingRepository,
        themeWalkingRepository : ThemeWalkingRepository
    ){
        self.walkingRepository = repository
        self.themeWalkingRepository = themeWalkingRepository
    }
    
    
    // 현재 걸음 모델
    @Published var currentWalkingModel : CurrentWalkingModel? = nil
    @Published var currentWalkingErrorMessage: String? = nil
    func loadCurrentWalkingModel(){
        Future<CurrentWalkingModel, Error> { promise in
            self.walkingRepository.loadCurrentWalkingCount { result in
                promise(result)
            }
        }
        .receive(on: DispatchQueue.main) // 메인 스레드에서 결과 처리
        .sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.currentWalkingErrorMessage = error.localizedDescription
                print("Error -> WalkingVM, loadCurrentWalkingModel // Exception : 현재 걸음 수 로드 실패: \(error.localizedDescription)")
            case .finished:
                self?.currentWalkingErrorMessage = nil
                break
            }
        } receiveValue: { [weak self] model in
            self?.currentWalkingModel = model
            print("Debug -> WalkingVM, loadCurrentWalkingModel // 현재 걸음 수 로드 성공 : \(model)")
        }
        .store(in: &cancellables) // 구독 저장
    }
    
    // 테마 걷기 모델 리스트
    // MARK: - 테마 걷기 모델 리스트
    @Published var themeWalkingList: [ThemeWalkingModel] = []
    @Published var isLoading: Bool = false
    @Published var hasMoreData: Bool = true
    @Published var errorMessage: String? = nil
      
    let pageSize = 6
    private var currentPage = 0
    // 테마 걷기 리스트 초기 로드
    func loadThemeWalkingList() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 0
        errorMessage = nil
        
        print("Debug -> WalkingVM, loadThemeWalkingList // 테마 걷기 리스트 초기 로드 시작")

        themeWalkingRepository.fetchThemeWalkingList(page: currentPage, limit: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.hasMoreData = false
                    print("Error -> WalkingVM, loadThemeWalkingList // Exception : 테마 걷기 리스트 로드 실패: \(error.localizedDescription)")
                case .finished:
                    print("Debug -> WalkingVM, loadThemeWalkingList // 테마 걷기 리스트 로드 완료")
                    break
                }
            } receiveValue: { [weak self] themes in
                guard let self = self else { return }
                self.themeWalkingList = themes
                self.currentPage = 1
                self.hasMoreData = themes.count >= self.pageSize
                print("Debug -> WalkingVM, loadThemeWalkingList // 테마 걷기 리스트 로드 성공: \(themes.count)개")
            }
            .store(in: &cancellables)
    }
    
    // 리스트 새로고침
    func refreshThemeWalkingList() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 0
        errorMessage = nil
        
        print("Debug -> WalkingVM, refreshThemeWalkingList // 테마 걷기 리스트 새로고침 시작")

        themeWalkingRepository.refreshThemeWalkingList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error -> WalkingVM, refreshThemeWalkingList // Exception : 테마 걷기 리스트 새로고침 실패: \(error.localizedDescription)")
                case .finished:
                    print("Debug -> WalkingVM, refreshThemeWalkingList // 테마 걷기 리스트 새로고침 완료")
                    break
                }
            } receiveValue: { [weak self] themes in
                guard let self = self else { return }
                // 첫 페이지만 표시 (pageSize만큼)
                let firstPageThemes = Array(themes.prefix(self.pageSize))
                self.themeWalkingList = firstPageThemes
                self.currentPage = 1
                self.hasMoreData = themes.count > self.pageSize
                print("Debug -> WalkingVM, refreshThemeWalkingList // 테마 걷기 리스트 새로고침 성공: \(firstPageThemes.count)개")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 3. 페이지네이션 (더 로드하기)
    func pagenation(currentPageIndex: Int, nextPageIndex: Int) {
        guard !isLoading && hasMoreData else {
            print("Debug -> WalkingVM, pagenation // 페이지네이션 중단: isLoading=\(isLoading), hasMoreData=\(hasMoreData)")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("Debug -> WalkingVM, pagenation // 페이지네이션 시작: 현재페이지=\(currentPageIndex), 다음페이지=\(nextPageIndex)")

        themeWalkingRepository.fetchThemeWalkingList(page: nextPageIndex, limit: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error -> WalkingVM, pagenation // Exception : 페이지네이션 실패: \(error.localizedDescription)")
                case .finished:
                    print("Debug -> WalkingVM, pagenation // 페이지네이션 완료")
                    break
                }
            } receiveValue: { [weak self] themes in
                guard let self = self else { return }
                
                if themes.isEmpty {
                    self.hasMoreData = false
                    print("Debug -> WalkingVM, pagenation // 페이지네이션 : 더 이상 로드할 데이터 없음")
                } else {
                    self.themeWalkingList.append(contentsOf: themes)
                    self.currentPage = nextPageIndex + 1
                    self.hasMoreData = themes.count >= self.pageSize
                    print("Debug -> WalkingVM, pagenation // 페이지네이션 성공: \(themes.count)개 추가, 총 \(self.themeWalkingList.count)개")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 4. 테마 추가
    func addTheme(_ theme: ThemeWalkingModel) {
        guard !isLoading else {
            print("Debug -> WalkingVM, addTheme // 테마 추가 중단: 현재 로딩 중")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        themeWalkingRepository.addTheme(model: theme)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error -> WalkingVM, addTheme // Exception : 테마 추가 실패: \(error.localizedDescription)")
                case .finished:
                    print("Debug -> WalkingVM, addTheme // 테마 추가 완료")
                    break
                }
            } receiveValue: { [weak self] _ in
                print("Debug -> WalkingVM, addTheme // 테마 추가 성공, 리스트 새로고침 시작")

                // 테마 추가 성공 후 리스트 새로고침
                self?.refreshThemeWalkingList()
            }
            .store(in: &cancellables)
    }
    
    func clearErrorMessage() {
        errorMessage = nil
        currentWalkingErrorMessage = nil
    }
    
    /// 9. 현재 상태 초기화
       func resetState() {
           themeWalkingList.removeAll()
           currentPage = 0
           hasMoreData = true
           isLoading = false
           errorMessage = nil
           currentWalkingModel = nil
           currentWalkingErrorMessage = nil
           
           print("Debug -> WalkingVM // 상태 초기화 완료")

       }
    
    deinit {
        cancellables.removeAll()
        print("Debug -> WalkingVM 메모리 해제")
    }
  
}

/*
 1. 데이터만 전달하는데 DispatchQueue를 main으로 서야하나? backgorund로 써야하나?
 2. receive(on), receive(subscriber)의 차이점은?
 3. Combine, Future에 대해서
 4. 패턴에 대해서 -> xml과 선언형 Ui에 공통적으로 사용할 수 있느 패턴을 개발한다면?
 5. API?
 6. HTTP?
 7.
 */
