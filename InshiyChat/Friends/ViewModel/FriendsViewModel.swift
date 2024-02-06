//
//  HomeViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 12.12.2023.
//

import Foundation

class FriendsViewModel {
    
    private let friendsModel: FriendsModel
    
    init(friendsModel: FriendsModel) {
        self.friendsModel = friendsModel
    }
    
    func getCurrentUserUID() -> String? {
        friendsModel.getCurrentUserUID()
    }
    
    func fetchFriends(completion: @escaping ([FriendsSectionItem]) -> Void) {
        friendsModel.fetchFriends(completion: completion)
    }
}
