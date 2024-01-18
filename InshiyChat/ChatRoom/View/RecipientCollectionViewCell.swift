//
//  RecipientCollectionViewCell.swift
//  InshiyChat
//
//  Created by Denys Astapov on 19.12.2023.
//

import UIKit

class RecipientCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "RecipientCollectionViewCell"
    
    let senderMessage: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let messageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "bfbfbf")
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageContainer.addSubview(senderMessage)
        contentView.addSubview(messageContainer)
        
        setUpConstraints()
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowRadius = 3
        contentView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            messageContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -100),
            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            senderMessage.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 15),
            senderMessage.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 12),
            senderMessage.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -15),
            senderMessage.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with message: MessageDTO) {
        senderMessage.text = message.text
        layoutIfNeeded()
    }
}
