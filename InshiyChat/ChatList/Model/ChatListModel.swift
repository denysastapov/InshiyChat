//
//  ChatListModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import Foundation

struct ChatSection: Hashable {
    let id = UUID()
    var items: [ChatSectionItem]
}

struct ChatSectionItem: Hashable {
    let id = UUID()
    let chatUID: String
    let friendUID: String
    let name: String
    let avatar: String
    var lastMessage: String
    let unreadAmount: String
}
