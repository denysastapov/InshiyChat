//
//  ScreenProvider.swift
//  InshiyChat
//
//  Created by Denys Astapov on 02.02.2024.
//

import UIKit

enum ScreenID {
    case login
    case homeScreen
}

class ScreenProvider {
    
    private var screens:[ScreenID: UIViewController] = [:]
    
    func setScreenWithID(id: ScreenID, screen: UIViewController) {
        screens[id] = screen
    }
    
    func getScreenWithID(id: ScreenID) -> UIViewController? {
        screens[id]
    }
    
}
