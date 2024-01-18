//
//  ChatListViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 31.12.2023.
//

import Foundation
import Firebase

class ChatListViewModel {
    
    var onChatUpdated: ((Int, Int) -> Void)?
    var updateUI: (() -> Void)?
    var chatSections: [ChatSection] = [] {
        didSet {
            updateUI?()
        }
    }
    
    func getCurrentUserUID() -> String? {
        
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        } else {
            return nil
        }
    }
    func loadInitialChatRooms() {
        guard let currentUserUID = getCurrentUserUID() else {
            print("No current user UID found")
            return
        }

        let chatRoomsRef = Database.database().reference().child("chatRooms")
        chatRoomsRef.observeSingleEvent(of: .value) { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("Error fetching ChatRoom \(chatRoomsRef): \(error)")
                return
            }

            guard let chatRoomsData = snapshot.value as? [String: Any] else {
                print("Failed to fetch chat rooms")
                return
            }

            var loadedChatRooms: [ChatSectionItem] = []
            let usersRef = Database.database().reference().child("users")

            let group = DispatchGroup()
            for (chatRoomUID, data) in chatRoomsData {
                if let chatRoomInfo = data as? [String: Any],
                   let userUIDs = chatRoomInfo["userUIDs"] as? [String],
                   userUIDs.contains(currentUserUID),
                   let friendUID = userUIDs.first(where: { $0 != currentUserUID }),
                   let lastMessageText = chatRoomInfo["chatLastMessage"] as? String {

                    group.enter()
                    usersRef.child(friendUID).observeSingleEvent(of: .value) { (userSnapshot, error) in
                        if let error = error {
                            print("Error fetching user data for friendUID \(friendUID): \(error)")
                            group.leave()
                            return
                        }

                        if let userData = userSnapshot.value as? [String: Any],
                           let name = userData["name"] as? String,
                           let avatar = userData["avatar"] as? String {

                            let chatRoom = ChatSectionItem(
                                chatUID: chatRoomUID,
                                friendUID: friendUID,
                                name: name,
                                avatar: avatar,
                                lastMessage: lastMessageText,
                                unreadAmount: ""
                            )

                            loadedChatRooms.append(chatRoom)
                        } else {
                            print("### Failed to fetch user data for friendUID: \(friendUID)")
                        }
                        group.leave()
                    }
                } else {
                    print("### Wrong data received")
                }
            }
            group.notify(queue: .main) {
                strongSelf.chatSections = [ChatSection(items: loadedChatRooms)]
                strongSelf.updateUI?()
            }
        }
    }
    
    func observeChatsLastMessages(completion: @escaping (String, String) -> Void) {
        let chatRoomsRef = Database.database().reference().child("chatRooms")
        
        chatRoomsRef.observe(.childAdded) { [weak self] snapshot in
            let chatRoomUID = snapshot.key
            self?.observeLastMessage(for: chatRoomUID, completion: completion)
        }
    }
    
    private func observeLastMessage(for chatRoomUID: String, completion: @escaping (String, String) -> Void) {
        let lastMessageRef = Database.database().reference().child("chatRooms").child(chatRoomUID).child("chatLastMessage")
        
        lastMessageRef.observe(.value) { snapshot in
            if let chatLastMessageText = snapshot.value as? String {
                completion(chatRoomUID, chatLastMessageText)
            }
        }
    }
    
    func updateChatRoom(with newMessage: String, for chatRoomUID: String) {
        for (sectionIndex, var section) in chatSections.enumerated() {
            if let itemIndex = section.items.firstIndex(where: { $0.chatUID == chatRoomUID }) {
                var updatedItem = section.items[itemIndex]
                updatedItem.lastMessage = newMessage
                
                section.items.remove(at: itemIndex)
                section.items.insert(updatedItem, at: 0)
                chatSections[sectionIndex] = section

                onChatUpdated?(sectionIndex, 0)
                break
            }
        }
    }
}
