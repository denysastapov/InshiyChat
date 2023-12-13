//
//  HomeCollectionViewCell.swift
//  InshiyChat
//
//  Created by Denys Astapov on 08.12.2023.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeCollectionViewCell"
    
    let userNameLabel: UILabel = {
        let label = CreateUIElements.makeSmallLabel(
            text: "",
            textColor: "000000",
            fontSize: 18,
            fontWeight: .bold
        )
        return label
    }()
    
    let userlastMessage: UILabel = {
        let label = CreateUIElements.makeSmallLabel(
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            textColor: "000000",
            fontSize: 14,
            fontWeight: .light
        )
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    var userAvatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile_def"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var stackViewUserLabels: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            userNameLabel,
            userlastMessage
        ])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var stackViewUserInfo: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            userAvatarImageView,
            stackViewUserLabels
        ])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackViewUserInfo)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .white
        let borderBottom = CALayer()
        borderBottom.backgroundColor = UIColor(hex: "F0F0F0").cgColor
        borderBottom.frame = CGRect(
            x: 0,
            y: contentView.frame.height - 1,
            width: contentView.frame.width,
            height: 1
        )
        contentView.layer.addSublayer(borderBottom)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            userNameLabel.heightAnchor.constraint(equalToConstant: 18),
            
            stackViewUserInfo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackViewUserInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20),
            stackViewUserInfo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 75),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func configure(with user: CellDTO) {
        userNameLabel.text = user.friend
        guard let imageUrl = URL(string: user.userAvatar) else {
            userAvatarImageView.image = UIImage(named: "profile_def")
            return
        }
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.userAvatarImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.userAvatarImageView.image = UIImage(named: "profile_def")
                }
            }
        }
    }
    
    struct CellDTO {
        let friend: String
        let userAvatar: String
    }
}
