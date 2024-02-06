//
//  ChatListCollectionViewCell.swift
//  InshiyChat
//
//  Created by Denys Astapov on 02.01.2024.
//

import UIKit

class ChatListCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ChatListCollectionViewCell"
    
    private var currentAvatarUrlHash: Int?
    
    let userNameLabel: UILabel = {
        let label = CreateUIElements.makeSmallLabel(
            text: "",
            textColor: "000000",
            fontSize: 18,
            fontWeight: .bold
        )
        return label
    }()
    
    let userLastMessage: UILabel = {
        let label = CreateUIElements.makeSmallLabel(
            text: "There is no messages yet.",
            textColor: "000000",
            fontSize: 14,
            fontWeight: .light
        )
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()

    let numberOfUnreadMessages: UILabel = {
        let label = CreateUIElements.makeSmallLabel(
            text: "14",
            textColor: "ffffff",
            fontSize: 12,
            fontWeight: .light
        )
        label.backgroundColor = UIColor(hex: "412dc4")
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 9
        label.textAlignment = .center
        label.isHidden = true
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
            userLastMessage
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
        contentView.addSubview(numberOfUnreadMessages)
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
            stackViewUserInfo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackViewUserInfo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            numberOfUnreadMessages.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            numberOfUnreadMessages.widthAnchor.constraint(equalToConstant: 20),
            numberOfUnreadMessages.heightAnchor.constraint(equalToConstant: 20),
            numberOfUnreadMessages.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 75),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func configure(with user: ChatListCellDTO) {
        if userNameLabel.text != user.userName {
            userNameLabel.text = user.userName
        }

        userLastMessage.text = user.lastMessage

        if !user.numberOfUnread.isEmpty, let intValue = Int(user.numberOfUnread), intValue > 0 {
            numberOfUnreadMessages.isHidden = false
            numberOfUnreadMessages.text = user.numberOfUnread
        } else {
            numberOfUnreadMessages.isHidden = true
        }

        let newAvatarUrlHash = user.userAvatar.hashValue
        if currentAvatarUrlHash != newAvatarUrlHash {
            currentAvatarUrlHash = newAvatarUrlHash
            updateAvatarImage(with: user.userAvatar)
        }
    }
    
    private func updateAvatarImage(with urlString: String) {
            guard let imageUrl = URL(string: urlString) else {
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
    
    struct ChatListCellDTO {
        let userName: String
        let userAvatar: String
        let lastMessage: String
        let numberOfUnread: String
    }
}
