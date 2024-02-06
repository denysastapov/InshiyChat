//
//  DateSeparatorCollectionViewCell.swift
//  InshiyChat
//
//  Created by Denys Astapov on 18.01.2024.
//

import UIKit

class DateSeparatorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "DateSeparatorCell"
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with message: MessageDTO) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mm"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: message.timeStamp))
        dateLabel.text = dateString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


