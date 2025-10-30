//
//  WalkingRecord.swift
//  FootHeart
//
//  Created by Jupond on 6/18/25.
//
import UIKit
import CoreLocation

class StepCheckerButton : UIButton {
    
    private var clickedInt: Int = 0
       
    init() {
        super.init(frame: .zero)
        setupUI()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setTitle("걸음수 0", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        backgroundColor = .systemBlue
        layer.cornerRadius = 12
        clipsToBounds = true
        
        // 패딩 적용
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
    
    private func setupAction() {
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        clickedInt += 1
        updateTitle()
    }
    
    private func updateTitle() {
        setTitle("걸음수 \(clickedInt)", for: .normal)
    }
    
    func getStepCount() -> Int {
        return clickedInt
    }
    
    // 걸음수 초기화 메소드
    func resetStepCount() {
        clickedInt = 0
        updateTitle()
    }
}


//
//struct WalkingRecordModel : Hashable {
//    let id: String
//    let startDate: Date
//    let endDate: Date
//    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }
//    let autoStepCount: Int      // 센서로 측정된 걸음수
//    let manualStepCount: Int    // 수동으로 측정된 걸음수
//    let distance: Double        // 미터 단위
//    let route: [CLLocationCoordinate2D] // 이동 경로
//    
//    // MARK: - Hashable 구현 (효율적인 해시)
//    func hash(into hasher: inout Hasher) {
//        // ID만으로 해시 생성 (고유 식별자이므로 충분)
//        hasher.combine(id)
//    }
//    
//    // MARK: - Equatable 구현 (Hashable이 Equatable을 상속받음)
//    static func == (lhs: WalkingRecordModel, rhs: WalkingRecordModel) -> Bool {
//        // ID가 같으면 같은 객체로 간주
//        return lhs.id == rhs.id
//    }
//    
//    // MARK: - 편의 이니셜라이저
//    init(startDate: Date, endDate: Date, autoStepCount: Int, manualStepCount: Int, distance: Double, route: [CLLocationCoordinate2D]) {
//        self.id = UUID().uuidString
//        self.startDate = startDate
//        self.endDate = endDate
//        self.autoStepCount = autoStepCount
//        self.manualStepCount = manualStepCount
//        self.distance = distance
//        self.route = route
//    }
//    
//    // MARK: - 계산 프로퍼티들
//    
//    /// 총 걸음수 계산
//    var totalStepCount: Int {
//        return autoStepCount + manualStepCount
//    }
//    
//    /// 평균 속도 계산 (km/h)
//    var averageSpeed: Double {
//        guard duration > 0 else { return 0 }
//        return (distance / 1000) / (duration / 3600)
//    }
//    
//    /// 거리 포맷팅
//    var formattedDistance: String {
//        if distance >= 1000 {
//            return String(format: "%.2f km", distance / 1000)
//        } else {
//            return String(format: "%.0f m", distance)
//        }
//    }
//    
//    /// 지속시간 포맷팅
//    var formattedDuration: String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .abbreviated
//        return formatter.string(from: duration) ?? ""
//    }
//    
//    /// 날짜 포맷팅
//    var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter.string(from: startDate)
//    }
//    
//    /// 시간 범위 포맷팅
//    var formattedTimeRange: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
//    }
//}


