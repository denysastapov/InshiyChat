//
//  Extension+.swift
//  InshiyChat
//
//  Created by Denys Astapov on 09.12.2023.
//

import UIKit
import Firebase

extension ContainerViewController: SideMenuViewControllerDelegate {
    
    func selectedCell(_ row: Int) {
        
        let newViewController: UIViewController
        switch row {
        case 0:
            let databaseManager = DatabaseManager()
            let friendsModel = FriendsModel(databaseManager: databaseManager)
            let friendsViewModel = FriendsViewModel(friendsModel: friendsModel)
            newViewController = FriendsViewController(viewModel: friendsViewModel)
        case 1:
            let databaseManager = DatabaseManager()
            let chatListModel = ChatListModel(databaseManager: databaseManager)
            let chatListViewModel = ChatListViewModel(chatListModel: chatListModel)
            newViewController = ChatListViewController(viewModel: chatListViewModel)
        case 2:
            newViewController = SettingsViewController()
        case 3:
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
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
