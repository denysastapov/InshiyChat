//
//  FriendsModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 18.12.2023.
//

import Foundation

struct FriendsModel {
    
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func getCurrentUserUID() -> String? {
        databaseManager.getCurrentUserUID()
    }
    
    func fetchFriends(completion: @escaping ([FriendsSectionItem]) -> Void) {
        databaseManager.fetchFriends(completion: completion)
    }
}

struct FriendsSection: Hashable {
    let id = UUID()
    let items: [FriendsSectionItem]
}

struct FriendsSectionItem: Hashable {
    let id = UUID()
    let uid: String
    let name: String
    let avatar: String
}
