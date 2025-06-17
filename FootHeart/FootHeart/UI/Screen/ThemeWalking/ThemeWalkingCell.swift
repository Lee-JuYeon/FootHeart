//
//  ThemeWalkingCell.swift
//  FootHeart
//
//  Created by Jupond on 6/12/25.
//

import UIKit
import CoreLocation

// MARK: - Collection View Cell
class ThemeWalkingCell: UICollectionViewCell {
    static let identifier = "ThemeWalkingCell"
        
        // MARK: - UI Components
        private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = 0.1
            view.layer.shadowRadius = 8
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.backgroundColor = .systemGray5
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .label
            label.numberOfLines = 1
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let durationLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .systemBlue
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let categoryBadge: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 8
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let categoryLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let categoryIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemGray
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let likeButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "heart"), for: .normal)
            button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
            button.tintColor = .systemRed
            button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            button.layer.cornerRadius = 15
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        private let likeCountLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            label.textColor = .systemRed
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let courseDistanceLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            label.textColor = .systemGreen
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let lockOverlay: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            view.layer.cornerRadius = 16
            view.isHidden = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let lockIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "lock.fill")
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        // 좋아요 버튼 액션을 위한 클로저
        var onLikeButtonTapped: ((String) -> Void)?
        private var currentThemeUID: String?
        
        // MARK: - Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
            setupActions()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup Methods
        private func setupViews() {
            contentView.addSubview(containerView)
            
            categoryBadge.addSubview(categoryLabel)
            
            containerView.addSubview(imageView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(descriptionLabel)
            containerView.addSubview(durationLabel)
            containerView.addSubview(categoryBadge)
            containerView.addSubview(categoryIcon)
            containerView.addSubview(likeButton)
            containerView.addSubview(likeCountLabel)
            containerView.addSubview(courseDistanceLabel)
            containerView.addSubview(lockOverlay)
            
            lockOverlay.addSubview(lockIcon)
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                // Container View
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                
                // Image View
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6),
                
                // Category Badge
                categoryBadge.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
                categoryBadge.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
                categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
                categoryBadge.heightAnchor.constraint(equalToConstant: 16),
                
                // Category Label
                categoryLabel.centerXAnchor.constraint(equalTo: categoryBadge.centerXAnchor),
                categoryLabel.centerYAnchor.constraint(equalTo: categoryBadge.centerYAnchor),
                categoryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryBadge.leadingAnchor, constant: 4),
                categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: categoryBadge.trailingAnchor, constant: -4),
                
                // Category Icon
                categoryIcon.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8),
                categoryIcon.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
                categoryIcon.widthAnchor.constraint(equalToConstant: 20),
                categoryIcon.heightAnchor.constraint(equalToConstant: 20),
                
                // Like Button
                likeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
                likeButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
                likeButton.widthAnchor.constraint(equalToConstant: 30),
                likeButton.heightAnchor.constraint(equalToConstant: 30),
                
                // Like Count Label
                likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 2),
                likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor),
                likeCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
                
                // Title Label
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                
                // Description Label
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                
                // Duration Label
                durationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
                durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                
                // Course Distance Label
                courseDistanceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
                courseDistanceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                courseDistanceLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
                
                // Lock Overlay
                lockOverlay.topAnchor.constraint(equalTo: containerView.topAnchor),
                lockOverlay.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                lockOverlay.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                lockOverlay.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                
                // Lock Icon
                lockIcon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
                lockIcon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
                lockIcon.widthAnchor.constraint(equalToConstant: 30),
                lockIcon.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        private func setupActions() {
            likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        }
        
        @objc private func likeButtonTapped() {
            guard let themeUID = currentThemeUID else { return }
            
            // 버튼 애니메이션
            UIView.animate(withDuration: 0.1, animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.likeButton.transform = .identity
                }
            }
            
            // 햅틱 피드백
            let impactGenerator = UIImpactFeedbackGenerator(style: .light)
            impactGenerator.impactOccurred()
            
            onLikeButtonTapped?(themeUID)
        }
        
        // MARK: - Configuration
        func configure(with item: ThemeWalkingModel, currentUserUID: String? = nil) {
            currentThemeUID = item.uid
            
            // 기본 정보 설정
            titleLabel.text = item.themeTitle
            descriptionLabel.text = item.themeDescription
            durationLabel.text = "⏱️ \(item.duration)"
            
            // 카테고리 설정
            categoryLabel.text = item.themeCategory.rawValue
            categoryBadge.backgroundColor = UIColor.red
            categoryIcon.image = UIImage(systemName: item.themeCategory.icon)
            
            // 좋아요 설정
            let likeCount = item.liked.count
            likeCountLabel.text = likeCount > 0 ? "\(likeCount)" : ""
            
            // 현재 사용자가 좋아요 했는지 확인
            if let userUID = currentUserUID {
                likeButton.isSelected = item.liked.contains(userUID)
            } else {
                likeButton.isSelected = false
            }
            
            // 코스 거리 계산 및 표시
            let courseDistance = calculateCourseDistance(locations: item.themeCourse)
            courseDistanceLabel.text = "📍 \(String(format: "%.1f", courseDistance))km"
            
            // 이미지 설정
            setupImage(with: item)
            
            // 잠금 상태 설정
            lockOverlay.isHidden = !item.isLocked
            
            // 셀 애니메이션
            setupCellAnimation()
        }
        
        private func setupImage(with item: ThemeWalkingModel) {
            // 썸네일 URL이 있으면 네트워크에서 로드, 없으면 로컬 이미지 사용
            if !item.themeThumbnailURL.isEmpty {
                loadImageFromURL(item.themeThumbnailURL)
            } else if !item.themeImagePath.isEmpty {
                imageView.image = UIImage(named: item.themeImagePath)
            } else {
                // 카테고리에 따른 기본 이미지 설정
                imageView.image = getDefaultImage(for: item.themeCategory)
            }
        }
        
        private func loadImageFromURL(_ urlString: String) {
            guard let url = URL(string: urlString) else {
                imageView.image = UIImage(systemName: "photo")
                return
            }
            
            // 간단한 이미지 로딩 (실제 프로젝트에서는 Kingfisher 등 사용 권장)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        }
        
        private func getDefaultImage(for category: ThemeCategory) -> UIImage? {
            switch category {
            case .nature:
                return UIImage(systemName: "leaf.circle.fill")
            case .city:
                return UIImage(systemName: "building.2.circle.fill")
            case .historical:
                return UIImage(systemName: "building.columns.circle.fill")
            case .fitness:
                return UIImage(systemName: "figure.run.circle.fill")
            case .meditation:
                return UIImage(systemName: "heart.circle.fill")
            }
        }
        
        private func calculateCourseDistance(locations: [CLLocation]) -> Double {
            guard locations.count > 1 else { return 0.0 }
            
            var totalDistance: Double = 0.0
            
            for i in 0..<(locations.count - 1) {
                let distance = locations[i].distance(from: locations[i + 1])
                totalDistance += distance
            }
            
            // 미터를 킬로미터로 변환
            return totalDistance / 1000.0
        }
        
        private func setupCellAnimation() {
            contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.contentView.transform = .identity
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.image = nil
            titleLabel.text = nil
            descriptionLabel.text = nil
            durationLabel.text = nil
            categoryLabel.text = nil
            likeCountLabel.text = nil
            courseDistanceLabel.text = nil
            lockOverlay.isHidden = true
            likeButton.isSelected = false
            currentThemeUID = nil
        }
}
