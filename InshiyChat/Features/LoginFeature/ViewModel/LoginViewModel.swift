//
//  ViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 05.12.2023.
//

import UIKit
import Firebase
import KeychainSwift

class LoginViewModel {
    
    var navigationController: UINavigationController?
    var showAlert: ((String?) -> Void)?
    
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
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }

            if let error = error as NSError? {
                self.handleSignInError(error)
            } else if let user = result?.user {
                user.getIDTokenForcingRefresh(true) { (idToken, error) in
                    if let error = error {
                        self.showAlert?("Error getting authentication token: \(error.localizedDescription)")
                    } else if let idToken = idToken {
                        self.handleToken(token: idToken)
                        let databaseManager = DatabaseManager()
                        let sideMenuModel = SideMenuModel(databaseManager: databaseManager)
                        let sideMenuViewModel = SideMenuViewModel(sideMenuModel: sideMenuModel)
                        self.navigationController?.pushViewController(
                            ContainerViewController(viewModel: sideMenuViewModel), 
                            animated: true
                        )
                    }
                }
            }
        }
    }

    func handleSignInError(_ error: NSError) {
        if error.code == AuthErrorCode.userNotFound.rawValue {
            self.showAlert?("User not found. Please register.")
        } else if error.code == AuthErrorCode.wrongPassword.rawValue {
            self.showAlert?("Wrong password. Please enter the correct password.")
        } else {
            self.showAlert?("Error signing in, check your email and/or password.")
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    func handleToken(token: String) {
        let keychain = KeychainSwift()
        keychain.set(token, forKey: "firebaseAuthToken")
    }
    
    func registerUser() {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (result, error) in
            if let error = error as? NSError {
                if error.domain == AuthErrorDomain && error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showAlert?("The email address is already in use by another account.")
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
