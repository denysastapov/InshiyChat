//
//  CreateUIElements.swift
//  InshiyChat
//
//  Created by Denys Astapov on 05.12.2023.
//

import UIKit

class CreateUIElements {
    
    static func makeTextField(placeholder: String,
                              isSecureTextEntry: Bool = false) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(hex: "F6F6F6")
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor(hex: "F6F6F6").cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.masksToBounds = false
        textField.keyboardType = .default
        textField.isSecureTextEntry = isSecureTextEntry
        textField.textColor = UIColor(hex: "A4A4A4")
        textField.layer.shadowColor = UIColor.gray.cgColor
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: "A4A4A4")]
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: placeholderAttributes
        )
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    static func makeBigLabel(text: String, fontSize: CGFloat, fontWeight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(hex: "412dc4")
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.layer.masksToBounds = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.3
        label.layer.shadowOffset = CGSize(width: 0, height: 4)
        label.layer.shadowRadius = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func makeSmallLabel(
        text: String,
        textColor: String,
        fontSize: CGFloat,
        fontWeight: UIFont.Weight
    ) -> UILabel {
            let label = UILabel()
            label.text = text
            label.textColor = UIColor(hex: "\(textColor)")
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            label.layer.masksToBounds = false
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
    }
    
    static func makeButton(backgroundColor: UIColor, titleColor: UIColor, title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = backgroundColor
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
