//
//  SettingsViewController.swift
//  InshiyChat
//
//  Created by Denys Astapov on 09.12.2023.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        if let rootViewController = self.navigationController?.viewControllers.first as? ContainerViewController {
            rootViewController.title = self.title
        }
        view.backgroundColor = .red

    }
    
}
