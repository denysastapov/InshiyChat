//
//  SideMenuModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 01.02.2024.
//

import UIKit

struct SideMenuModel {
    
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func fetchCurrentUser(completion: @escaping (UserInfo?) -> Void) {
        databaseManager.getCurrentUserForSideMenu(completion: completion)
    }
}

struct UserInfo {
    let name: String?
    let userName: String?
    let phone: String?
    let avatarImage: UIImage?
}
struct SideMenuItem {
    var icon: UIImage
    var title: String
}
