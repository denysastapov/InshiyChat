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
    
    private var userName = ""
    private var userEmail = ""
    private var userPassword = ""
    
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
    
    func autorizeUser() {
        Auth.auth().signIn(withEmail: self.userEmail, password: self.userPassword) { (result, error) in
            if error == nil {
//                self.navigationController?.pushViewController(HomeViewController(), animated: true)
            }
        }
    }
    
    func registerUser()  {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (result, error) in
            if error == nil {
                if let result = result {
                    print("New user with ID \(result.user.uid)")
                    let reference = Database.database().reference().child("users")
                    reference.child(result.user.uid).updateChildValues(["name": self.userName, "email": self.userEmail])
                    self.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
            }
        }
    }
}
