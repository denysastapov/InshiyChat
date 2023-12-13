//
//  SceneDelegate.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController()
        loginViewController.viewModel = loginViewModel
        let rootViewController = UINavigationController(rootViewController: loginViewController)
//        let rootViewController = UINavigationController(rootViewController: HomeViewController())
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }
}

