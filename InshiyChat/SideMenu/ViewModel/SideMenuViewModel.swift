//
//  SideMenuViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 11.12.2023.
//

import UIKit

class SideMenuViewModel {
    
    private let sideMenuModel: SideMenuModel
    
    init(sideMenuModel: SideMenuModel) {
        self.sideMenuModel = sideMenuModel
    }
    
    func fetchCurrentUser(completion: @escaping (UserInfo?) -> Void) {
        sideMenuModel.fetchCurrentUser(completion: completion)
    }
}
