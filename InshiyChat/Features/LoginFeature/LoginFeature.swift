//
//  LoginFeature.swift
//  InshiyChat
//
//  Created by Denys Astapov on 02.02.2024.
//

import UIKit

class LoginFeature: Feature {
    
    private let screenProvider: ScreenProvider
    
    init(screenProvider: ScreenProvider) {
        self.screenProvider = screenProvider
    }
    
    func performSetUp() async {
        screenProvider.setScreenWithID(
            id: .login,
            screen: getLoginScreen()
        )
    }
    
    func getLoginScreen() -> UIViewController {
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController()
        loginViewController.viewModel = loginViewModel
        return loginViewController
    }
    
}
