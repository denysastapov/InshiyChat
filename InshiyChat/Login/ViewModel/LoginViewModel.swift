//
//  ViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 05.12.2023.
//

import UIKit
import Firebase

class LoginViewModel {
    
    var navigationController: UINavigationController?
    var showAlertClosure: ((String?) -> Void)?
    
    private var userName = ""
    private var userEmail = ""
    private var userPassword = ""
    
    private var loginUserEmail = ""
    private var loginUserPassword = ""
    
    var isUserNameValid: ((Bool) -> ())!
    var isUserEmailValid: ((Bool) -> ())!
    var isUserPasswordValid: ((Bool) -> ())!

    func setUpUserName(userFirstName: String) {
        self.userName = userFirstName
        ValidationFieldsHelper.isValidName(userName) ? isUserNameValid(true) : isUserNameValid(false)
    }
    
    func setUpUserEmail(userEmail: String) {
        self.userEmail = userEmail
        ValidationFieldsHelper.isValidEmail(userEmail) ? isUserEmailValid(true) : isUserEmailValid(false)
    }
    
    func setUpUserPassword(userPassword: String) {
        self.userPassword = userPassword
        ValidationFieldsHelper.isValidPassword(userPassword) ? isUserPasswordValid(true) : isUserPasswordValid(false)
    }
    
    func isValidRegistration() -> Bool {
        return ValidationFieldsHelper.isValidName(userName) &&
        ValidationFieldsHelper.isValidEmail(userEmail) &&
        ValidationFieldsHelper.isValidPassword(userPassword)
    }
    
    func autorizeUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.navigationController?.pushViewController(HomeViewController(), animated: true)
            }
        }
    }
    
    func registerUser() {
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (result, error) in
                if let error = error as? NSError {
                    if error.domain == AuthErrorDomain && error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        print("Error Email in use")
                        self.showAlertClosure?("The email address is already in use by another account.")
                    } else {
                        print("Error creating user: \(error.localizedDescription)")
                    }
                } else {
                    if let result = result {
                        let reference = Database.database().reference().child("users")
                        reference.child(result.user.uid).updateChildValues([
                            "name": self.userName,
                            "email": self.userEmail
                        ])
                    }
                }
            }
        }
}
