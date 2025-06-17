//
//  PedometerLabel.swift
//  FootHeart
//
//  Created by Jupond on 5/19/25.
//
import UIKit
import CoreMotion
import CoreLocation

class PedometerLabel: UIView {
    
    // 만보기 표시를 위한 라벨 추가
    private let stepCountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let stepCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 걸음"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()

        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()

    }
    
    
    private func setUI() {
        self.addSubview(stepCountView)
        stepCountView.addSubview(stepCountLabel)
        
        // 걸음 수 뷰가 맵 위에 오도록 레이어 설정
        stepCountView.layer.zPosition = 1000
        
        NSLayoutConstraint.activate([
            // 걸음 수 뷰 컨테이너 위치 설정
            stepCountView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            stepCountView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            stepCountView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            stepCountView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            // 걸음 수 라벨 위치 설정
            stepCountLabel.topAnchor.constraint(equalTo: stepCountView.topAnchor),
            stepCountLabel.leadingAnchor.constraint(equalTo: stepCountView.leadingAnchor, constant: 10),
            stepCountLabel.trailingAnchor.constraint(equalTo: stepCountView.trailingAnchor, constant: -10),
            stepCountLabel.bottomAnchor.constraint(equalTo: stepCountView.bottomAnchor)
        ])
    }
    
    
    // 만보기를 위한 모션 권한 설정
    private func setPermission(){
        if CMPedometer.isStepCountingAvailable() {
            print("걸음 수 측정 가능")
        } else {
            print("걸음 수 측정 불가")
        }
    }
    
    
    private var stepCount: Int = 0
    private let pedometer = CMPedometer()
    func updateStepCount(steps : Int){
        stepCount = steps
        stepCountLabel.text = "\(steps) 🚶🏻"
    }
    
    private var stepCountingStartTime: Date?
    func startStepCount(){
        // 시작 시간부터 걸음 수 측정 시작
        stepCountingStartTime = Date()
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: stepCountingStartTime!) { [weak self] data, error in
                guard let self = self, let data = data, error == nil else {
                    print("걸음 수 측정 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    return
                }
                
                // UI 업데이트는 메인 스레드에서
                DispatchQueue.main.async {
                    self.updateStepCount(steps : Int(truncating: data.numberOfSteps))
                }
            }
        }
    }
    
    func stopStepCount(){
        pedometer.stopUpdates()
    }
    
    deinit {
        pedometer.stopUpdates()
    }
}

