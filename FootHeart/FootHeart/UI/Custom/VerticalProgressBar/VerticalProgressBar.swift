//
//  VerticalProgressBar.swift
//  FootHeart
//
//  Created by Jupond on 8/23/25.
//

import UIKit

class VerticalProgressBar: UIView {
    
    private var progress: Float = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var progressHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(trackView)
        addSubview(progressFillView)
        
        NSLayoutConstraint.activate([
            // Track View (배경) - 전체 영역
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Progress Fill View (채움) - 하단에서 시작해서 위로 채워짐
            progressFillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressFillView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressFillView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // 초기 높이 0으로 설정
        progressHeightConstraint = progressFillView.heightAnchor.constraint(equalToConstant: 0)
        progressHeightConstraint.isActive = true
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        self.progress = max(0, min(1, progress))
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                self.updateProgress()
                self.layoutIfNeeded()
            }
        } else {
            updateProgress()
        }
    }
    
    private func updateProgress() {
        let totalHeight = bounds.height
        let fillHeight = totalHeight * CGFloat(progress)
        progressHeightConstraint.constant = fillHeight
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgress()
    }
    
    // 색상 커스터마이징
    func setTrackColor(_ color: UIColor) {
        trackView.backgroundColor = color
    }
    
    func setProgressColor(_ color: UIColor) {
        progressFillView.backgroundColor = color
    }
}
