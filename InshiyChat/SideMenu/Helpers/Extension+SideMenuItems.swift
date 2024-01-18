//
//  Extension+.swift
//  InshiyChat
//
//  Created by Denys Astapov on 09.12.2023.
//

import UIKit
import Firebase
import KeychainSwift

extension ContainerViewController: SideMenuViewControllerDelegate {
    
    func selectedCell(_ row: Int) {
        
        let newViewController: UIViewController
        switch row {
        case 0:
            newViewController = FriendsViewController()
        case 1:
            newViewController = ChatListViewController()
        case 2:
            newViewController = SettingsViewController()
        case 3:
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
            let keychain = KeychainSwift()
            keychain.delete("firebaseAuthToken")
            navigationController?.popToRootViewController(animated: true)
            navigationController?.isNavigationBarHidden = true
            return
        default:
            return
        }
        showViewController(newViewController)
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
        
    }
    
    func showViewController(_ viewController: UIViewController) {
        if let currentVC = self.mainViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        mainViewController = viewController
        addChild(viewController)
        view.insertSubview(viewController.view, at: 0)
        viewController.didMove(toParent: self)
        
        viewController.view.frame = view.bounds
    }
}
