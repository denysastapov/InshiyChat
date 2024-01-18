//
//  ContainerViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 02.01.2024.
//

import UIKit
import Firebase
import KeychainSwift

class ContainerViewController: UIViewController {
    
    var mainViewController: UIViewController!
    var sideMenuViewController: SideMenuViewController!
    var sideMenuShadowView: UIView!
    var sideMenuRevealWidth: CGFloat = 280
    let paddingForRotation: CGFloat = 150
    var isExpanded: Bool = false
    var draggingIsEnabled: Bool = false
    var panBaseLocation: CGFloat = 0.0
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var openSideMenuOnTop: Bool = true
    var gestureEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUserForSideMenu()
        
        mainViewController = ChatListViewController()
        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.didMove(toParent: self)
        
        setUpSideMenu()
        
    }
    
    func setUpSideMenu() {
        navigationController?.isNavigationBarHidden = false
        
        self.title = "Chats"
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.openSideMenu()
            }))
        menuButton.tintColor = .white
        navigationItem.leftBarButtonItem = menuButton
        
        self.setNavBarAppearance(tintColor: .white, barColor: UIColor(hex: "412dc4"))
        
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        self.sideMenuShadowView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
        if self.openSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }
        
        self.sideMenuViewController = SideMenuViewController()
        self.sideMenuViewController.delegate = self
        
        view.insertSubview(self.sideMenuViewController.view, at: self.openSideMenuOnTop ? 2 : 0)
        addChild(self.sideMenuViewController)
        self.sideMenuViewController.didMove(toParent: self)
        
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        if self.openSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -self.sideMenuRevealWidth - self.paddingForRotation
            )
            self.sideMenuTrailingConstraint.isActive = true
        }
        
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    func setNavBarAppearance(tintColor: UIColor, barColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barColor
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = tintColor
    }
    
    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.6 : 0.0
        }
    }
    
    func openSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.openSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.openSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.openSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}
