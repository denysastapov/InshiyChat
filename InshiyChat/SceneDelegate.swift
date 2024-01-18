//
//  SceneDelegate.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit
import Firebase
import KeychainSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if Auth.auth().currentUser != nil {
            let homeViewController = ContainerViewController()
            window.rootViewController = UINavigationController(rootViewController: homeViewController)
        } else {
            let loginViewModel = LoginViewModel()
            let loginViewController = LoginViewController()
            loginViewController.viewModel = loginViewModel
            window.rootViewController = UINavigationController(rootViewController: loginViewController)
        }
        window.makeKeyAndVisible()
    }
}

