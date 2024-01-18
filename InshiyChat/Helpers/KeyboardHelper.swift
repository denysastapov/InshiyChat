//
//  KeyboardHelper.swift
//  InshiyChat
//
//  Created by Denys Astapov on 05.12.2023.
//

import UIKit

extension ChatRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustForKeyboard(notification: notification, isShowing: true)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        adjustForKeyboard(notification: notification, isShowing: false)
    }

    func adjustForKeyboard(notification: Notification, isShowing: Bool) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        messageBoxBottomConstraint?.constant = isShowing ? -keyboardViewEndFrame.height : 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if isShowing {
                self.scrollToLastItem()
            }
        }
    }
}

