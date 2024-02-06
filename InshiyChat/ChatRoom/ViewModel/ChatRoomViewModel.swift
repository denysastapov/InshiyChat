//
//  ChatRoomViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 19.12.2023.
//

import Foundation
import Firebase

class ChatRoomViewModel {
    
    let dataBaseManager = DatabaseManager()
    
    func getCurrentUserUID(completion: @escaping (String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        let currentUserUID = currentUser.uid
        completion(currentUserUID)
    }
    
    func isChatExsists(
        userUID1: String,
        userUID2: String,
        completion: @escaping (String) -> Void
    ) {
        let sortedUserUIDs = [userUID1, userUID2].sorted()
        let chatUID = sortedUserUIDs.joined(separator: "_")
        
        let chatRef = Database.database().reference().child("chatRooms").child(chatUID)
        
        chatRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(chatUID)
            } else {
                self.createChatRoom(
                    chatUID: chatUID,
                    userUID1: userUID1,
                    userUID2: userUID2,
                    completion: completion
                )
            }
        }
    }
    
    private func createChatRoom(
        chatUID: String,
        userUID1: String,
        userUID2: String,
        completion: @escaping (String) -> Void
    ) {
        let chatRoomData: [String: Any] = [
            "chatLastMessage": String(),
            "messages": [],
            "userUIDs": [userUID1, userUID2]
        ]
        
        let chatRef = Database.database().reference().child("chatRooms").child(chatUID)
        
        chatRef.setValue(chatRoomData) { error, _ in
            if let error = error {
                print("Error creating chat room: \(error.localizedDescription)")
            } else {
                completion(chatUID)
            }
        }
    }
    
    func sendMessage(
        chatUID: String,
        messageOwner: String,
        text: String,
        timestamp: TimeInterval,
        completion: @escaping (Error?) -> Void
    ) {
        let databaseRef = Database.database().reference()
        let chatLastMessageRef = databaseRef.child("chatRooms").child(chatUID).child("chatLastMessage")
        let messageRef = databaseRef.child("chatRooms").child(chatUID).child("messages").childByAutoId()
        let messageData: [String: Any] = [
            "isRead": false,
            "messageOwner": messageOwner,
            "text": text,
            "timestamp": timestamp
        ]
        chatLastMessageRef.setValue(text) { (error, _) in
            completion(error)
        }
        messageRef.setValue(messageData) { (error, _) in
            completion(error)
        }
    }
    
    func getMessages(for chatUID: String, completion: @escaping ([MessageDTO]?, Error?) -> Void) {
        let messagesRef = Database.database().reference().child("chatRooms").child(chatUID).child("messages")
        
        messagesRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(nil, nil)
                return
            }
            
            var messages: [MessageDTO] = []
            for childSnapshot in snapshot.children {
                if let childData = childSnapshot as? DataSnapshot,
                   let messageData = childData.value as? [String: Any] {
                    if let message = self.parseMessageFromSnapshot(messageData) {
                        messages.append(message)
                    }
                }
            }
            completion(messages, nil)
        }
    }
    
    func parseMessageFromSnapshot(_ snapshot: [String: Any]) -> MessageDTO? {
        guard
            let text = snapshot["text"] as? String,
            let messageOwnerID = snapshot["messageOwner"] as? String,
            let timeStamp = snapshot["timestamp"] as? TimeInterval
        else {
            print("Cant convert the fields")
            return nil
        }

        let isRead: Bool
        if let isReadValue = snapshot["isRead"] as? Bool {
            isRead = isReadValue
        } else if let isReadNumber = snapshot["isRead"] as? Int {
            isRead = isReadNumber != 0
        } else {
            print("Cant convert isRead")
            return nil
        }
        let message = MessageDTO(
            text: text,
            timeStamp: timeStamp,
            messageOwnerID: messageOwnerID,
            isRead: isRead
        )
        return message
    }
    
    func observeNewMessages(for chatUID: String, completion: @escaping (MessageDTO) -> Void) {
        let messagesRef = Database.database().reference().child("chatRooms").child(chatUID).child("messages")
        messagesRef.observe(.childAdded, with: { snapshot in
            if let messageData = snapshot.value as? [String: Any],
               let message = self.parseMessageFromSnapshot(messageData) {
                completion(message)
            }
        })
    }

}
