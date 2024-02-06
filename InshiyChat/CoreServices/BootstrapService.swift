//
//  BootstrapService.swift
//  InshiyChat
//
//  Created by Denys Astapov on 02.02.2024.
//

import Foundation
import Firebase

class BootstrapService {
    
    private let databaseManager = DatabaseManager()
    private let screenProvider = ScreenProvider()
    
    private lazy var features: [Feature] = [
        LoginFeature(screenProvider: screenProvider)
    ]
    
    func setUp() async {
        await setUpFeatures()
        await launch()
    }
    
    private func launch() async {
        
    }
    
    private func getRootScreen() -> UIViewController? {
        if Auth.auth().currentUser != nil {
            let sideMenuModel = SideMenuModel(databaseManager: databaseManager)
            let sideMenuViewModel = SideMenuViewModel(sideMenuModel: sideMenuModel)
            let homeViewController = ContainerViewController(viewModel: sideMenuViewModel)
            return UINavigationController(rootViewController: homeViewController)
        } else {
            guard let loginViewController = screenProvider.getScreenWithID(id: .login) else { return nil }
            return UINavigationController(rootViewController: loginViewController)
        }
        
    }
    
    private func setUpFeatures() async {
        
    }
    
}
