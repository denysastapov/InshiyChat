//
//  ChatListViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import Foundation

class ChatListViewModel {
    
    private let chatListModel: ChatListModel
    
    var onChatUpdated: ((_ sectionIndex: Int, _ itemIndex: Int) -> Void)?
    var updateUI: (() -> Void)?
    var chatSections: [ChatSection] = [] {
        didSet {
            updateUI?()
        }
    }
    
    
    init(chatListModel: ChatListModel) {
        self.chatListModel = chatListModel
    }
    
    func loadInitialChatRooms(completion: @escaping ([ChatSectionItem]) -> Void) {
        chatListModel.loadInitialChatRooms(completion: completion)
    }
    
    func observeChatsLastMessages(completion: @escaping (String, String) -> Void) {
        chatListModel.observeChatsLastMessages(completion: completion)
    }
    
    func observeLastMessage(for chatRoomUID: String, completion: @escaping (String, String) -> Void) {
        chatListModel.observeLastMessage(for: chatRoomUID, completion: completion)
    }
    
    func updateChatRoom(with newMessage: String, for chatRoomUID: String) {
        chatListModel.updateChatRoom(with: newMessage, for: chatRoomUID)
    }
}
