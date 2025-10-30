//
//  DishCell.swift
//  FootHeart
//
//  Created by Jupond on 9/4/25.
//
import UIKit
class DishCell: UICollectionViewCell {
    static let identifier = "DishCell"
    
    private let dishImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.text = "음식 이름"
        label.textColor = .label
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let kcalLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .thin)
        label.text = "4,765kcal"
        label.textColor = .label
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "오늘 아침"
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(dishImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(kcalLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            // 이미지뷰 - 상단
            dishImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dishImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dishImageView.widthAnchor.constraint(equalToConstant: 80),
            dishImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // 텍스트 라벨 - 중간 왼쪽 (trailingAnchor 제거)
            nameLabel.topAnchor.constraint(equalTo: dishImageView.bottomAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),

            // kcal 라벨 - 중간 오른쪽 (nameLabel 옆에 위치)
            kcalLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0),
            kcalLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            kcalLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 0),
            kcalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            // time 라벨 - 하단 (nameLabel 아래, 전체 폭)
            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    
    func configure(with dish: DishModel) {
        loadImageFromServer(urlString: dish.imageURL)
        nameLabel.text = "\(dish.name)"
        kcalLabel.text = ""
        timeLabel.text = FormatManager.shared.formatEatenTime(mealType: dish.mealPattern)
    }
    
    private func loadImageFromServer(urlString: String) {
        // 기본 이미지 설정
        dishImageView.image = UIImage(systemName: "photo")
        
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            return
        }
        
        // 서버에서 이미지 로드
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.dishImageView.image = image
            }
        }.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dishImageView.image = UIImage(systemName: "photo") // 기본 이미지로 리셋
        nameLabel.text = nil
        nameLabel.isHidden = false
        timeLabel.text = nil
        kcalLabel.text = nil
        dishImageView.isHidden = false
        backgroundColor = .systemBackground
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 0
    }
}
