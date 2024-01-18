//
//  FriendsModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 18.12.2023.
//

import Foundation

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
