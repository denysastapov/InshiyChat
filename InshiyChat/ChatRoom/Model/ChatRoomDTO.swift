//
//  ChatRoomDTO.swift
//  InshiyChat
//
//  Created by Denys Astapov on 14.12.2023.
//

import Foundation

struct ChatRoomDTO: Hashable {
    let id = UUID()
    let messages: [MessageDTO]
    let usersIDs: [String]
}

struct MessageDTO: Hashable {
    let id = UUID()
    let text: String
    let timeStamp: TimeInterval
    let messageOwnerID: String
    let isRead: Bool
}
