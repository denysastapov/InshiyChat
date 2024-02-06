//
//  ChatListModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import Foundation

struct ChatListModel {
    
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func loadInitialChatRooms(completion: @escaping ([ChatSectionItem]) -> Void) {
        databaseManager.loadInitialChatRooms(completion: completion)
    }
    
    func observeChatsLastMessages(completion: @escaping (String, String) -> Void) {
        databaseManager.observeChatsLastMessages(completion: completion)
    }
    
    func observeLastMessage(for chatRoomUID: String, completion: @escaping (String, String) -> Void) {
        databaseManager.observeLastMessage(for: chatRoomUID) { chatRoomUID, lastMessageText in
            completion(chatRoomUID, lastMessageText)
        }
    }
    
    func updateChatRoom(with newMessage: String, for chatRoomUID: String) {
        databaseManager.updateChatRoom(with: newMessage, for: chatRoomUID)
    }

}

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
