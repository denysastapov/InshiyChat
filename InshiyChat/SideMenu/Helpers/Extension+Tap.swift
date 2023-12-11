//
//  Extension+.swift
//  InshiyChat
//
//  Created by Denys Astapov on 09.12.2023.
//

import UIKit

extension HomeViewController: SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int) {
        switch row {
        case 0:
            // Home
            self.showViewController(viewController: HomeViewController())
        case 1:
            // Music
            break
        case 2:
            // Movies
            break
        case 3:
            // Books
            break
        case 4:
            // Profile
            break
        case 5:
            // Settings
            self.showViewController(viewController: SettingsViewController())
        case 6:
            // Like us on facebook
            break
        default:
            break
        }
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }

    func showViewController<T: UIViewController>(viewController: T) {

        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
                (subview.superview as? UIViewController)?.didMove(toParent: nil)
            }
        }
        viewController.view.tag = 99
        view.insertSubview(viewController.view, at: self.openSideMenuOnTop ? 0 : 1)
        addChild(viewController)
        DispatchQueue.main.async {
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        if !self.openSideMenuOnTop {
            if isExpanded {
                viewController.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                viewController.view.addSubview(self.sideMenuShadowView)
            }
        }
        viewController.didMove(toParent: self)
    }
}

extension UIViewController {
    
    func openViewController() -> HomeViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is HomeViewController {
            return viewController! as? HomeViewController
        }
        while (!(viewController is HomeViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is HomeViewController {
            return viewController as? HomeViewController
        }
        return nil
    }
}
