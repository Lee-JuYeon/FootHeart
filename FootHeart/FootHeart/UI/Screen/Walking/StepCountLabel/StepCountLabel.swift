//
//  ChipView.swift
//  FootHeart
//
//  Created by Jupond on 8/4/25.
//
import UIKit

class StepCountLabel : UILabel {
        
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 현재 걸음 수를 저장하는 프로퍼티
    var stepCount: Int = 0 {
        didSet {
            text = "👟 \(stepCount)"
        }
    }
    
    private func setupUI() {
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textAlignment = .center
        textColor = .label
        backgroundColor = .systemYellow
        clipsToBounds = true
        text = "👟 0"
    }
      
    // 실제 크기가 결정된 후
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2  // 높이의 절반 = 완전한 둥근 모양, 고정값(25) 대신 동적으로 계산
    }
    
    // 텍스트 패딩 적용
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        super.drawText(in: rect.inset(by: insets))
    }
    
    // intrinsicContentSize도 패딩만큼 증가
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 32, height: size.height + 16)
    }
       
   
}



//
//class ChipView : UIButton {
//    
//    private var tapHandler: (() -> Void)?
//    
//    init(text: String, onTap: @escaping () -> Void) {
//        super.init(frame: .zero)
//        self.tapHandler = onTap
//        setupButton(with: text)
//        setupActions()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupButton(with: "버튼")
//        setupActions()
//    }
//    
//    // MARK: - Setup Methods
//    private func setupButton(with text: String) {
//        // 텍스트 설정
//        setTitle(text, for: .normal)
//        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        setTitleColor(.black, for: .normal)
//        
//        // 배경색 설정
//        backgroundColor = UIColor.yellow
//        
//        // 칩 모양 설정
//        layer.cornerRadius = 20
//        layer.masksToBounds = false
//        
//        // 그림자 효과
//        layer.shadowColor = UIColor.lightGray.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowOpacity = 0.3
//        layer.shadowRadius = 4
//        
//        // 내부 여백 설정
//        contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
//        
//        // Auto Layout 설정
//        translatesAutoresizingMaskIntoConstraints = false
//        
//        // 높이 제약 조건
//        heightAnchor.constraint(equalToConstant: 40).isActive = true
//    }
//    
//    private func setupActions() {
//        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
//        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
//    }
//    
//    // MARK: - Action Methods
//    @objc private func buttonTapped() {
//        // 햅틱 피드백
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        impactGenerator.impactOccurred()
//        
//        // 클릭 이벤트 실행
//        tapHandler?()
//    }
//    
//    @objc private func buttonTouchDown() {
//        // 터치 시작 애니메이션
//        UIView.animate(withDuration: 0.1) {
//            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//            self.backgroundColor = UIColor.systemBlue
//        }
//    }
//    
//    @objc private func buttonTouchUp() {
//        // 터치 종료 애니메이션
//        UIView.animate(withDuration: 0.1) {
//            self.transform = .identity
//            self.backgroundColor = UIColor.lightGray
//        }
//    }
//    
//    // MARK: - Public Methods
//    
//    /// 버튼 텍스트 업데이트
//    func updateText(_ text: String) {
//        setTitle(text, for: .normal)
//    }
//    
//    /// 클릭 이벤트 핸들러 업데이트
//    func updateTapHandler(_ handler: @escaping () -> Void) {
//        self.tapHandler = handler
//    }
//    
//    /// 성공 상태로 변경 (초록색)
//    func setSuccessState() {
//        UIView.animate(withDuration: 0.3) {
//            self.backgroundColor = UIColor.systemGreen
//            self.layer.shadowColor = UIColor.systemGreen.cgColor
//        }
//    }
//    
//    /// 기본 상태로 복원 (하늘색)
//    func setDefaultState() {
//        UIView.animate(withDuration: 0.3) {
//            self.backgroundColor = UIColor.lightGray
//            self.layer.shadowColor = UIColor.lightGray.cgColor
//        }
//    }
//    
//    /// 비활성화 상태로 변경
//    func setDisabledState() {
//        isEnabled = false
//        UIView.animate(withDuration: 0.3) {
//            self.backgroundColor = UIColor.systemGray
//            self.layer.shadowColor = UIColor.systemGray.cgColor
//            self.alpha = 0.6
//        }
//    }
//    
//    /// 활성화 상태로 변경
//    func setEnabledState() {
//        isEnabled = true
//        UIView.animate(withDuration: 0.3) {
//            self.backgroundColor = UIColor.lightGray
//            self.layer.shadowColor = UIColor.lightGray.cgColor
//            self.alpha = 1.0
//        }
//    }
//    
//    /// 축하 애니메이션
//    func playSuccessAnimation() {
//        setSuccessState()
//        
//        UIView.animate(withDuration: 0.2, animations: {
//            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//        }) { _ in
//            UIView.animate(withDuration: 0.2) {
//                self.transform = .identity
//            }
//        }
//        
//        // 성취 햅틱 피드백
//        let notificationGenerator = UINotificationFeedbackGenerator()
//        notificationGenerator.notificationOccurred(.success)
//    }
//       
//}
