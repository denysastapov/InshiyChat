//
//  DatabaseManager.swift
//  InshiyChat
//
//  Created by Denys Astapov on 19.01.2024.
//

import Foundation
import Firebase

class DatabaseManager {
    
    let databaseReference = Database.database().reference()
    
    var onChatUpdated: ((Int, Int) -> Void)?
    var updateUI: (() -> Void)?
    var chatSections: [ChatSection] = [] {
        didSet {
            updateUI?()
        }
    }
    
    func getCurrentUserUID() -> String? {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return nil
        }
        return currentUser.uid
    }
    
    func getCurrentUserForSideMenu(completion: @escaping (UserInfo?) -> Void) {
        guard let currentUser = getCurrentUserUID() else { return }
        let usersReference = databaseReference.child("users")
        
        usersReference.child(currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String: Any] {
                let name = userData["name"] as? String
                let userName = userData["username"] as? String
                let phone = userData["phone"] as? String
                
                if let avatarString = userData["avatar"] as? String, let avatarURL = URL(string: avatarString) {
                    URLSession.shared.dataTask(with: avatarURL) { (data, response, error) in
                        var userImage: UIImage? = nil
                        if let data = data {
                            userImage = UIImage(data: data)
                        }
                        DispatchQueue.main.async {
                            let userInfo = UserInfo(
                                name: name,
                                userName: userName,
                                phone: phone,
                                avatarImage: userImage
                            )
                            completion(userInfo)
                        }
                    }.resume()
                } else {
                    print("URL is not valid")
                    let defaultImage = UIImage(named: "profile_def")
                    let userInfo = UserInfo(
                        name: name,
                        userName: userName,
                        phone: phone,
                        avatarImage: defaultImage
                    )
                    completion(userInfo)
                }
            } else {
                print("Snapshot is not in expected format")
                completion(nil)
            }
        }) { (error) in
            print("Error receiving userdata: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func fetchFriends(completion: @escaping ([FriendsSectionItem]) -> Void) {
        guard let currentUser = getCurrentUserUID() else { return }
        
        databaseReference.child("users").child(currentUser).child("friendIDs").observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching data for friend IDs: \(error)")
                completion([])
                return
            }
            
            if !snapshot.exists() {
                print("No friend IDs found for user: \(currentUser)")
                completion([])
                return
            }
            
            guard let friendIDsDictionary = snapshot.value as? [String: String] else {
                print("Failed to cast friendIDs snapshot to dictionary")
                completion([])
                return
            }
            
            let friendIDs = Array(friendIDsDictionary.values)
            var friendsSectionItems: [FriendsSectionItem] = []
            
            let group = DispatchGroup()
            
            for friendID in friendIDs {
                group.enter()
                
                self.databaseReference.child("users").child(friendID).observeSingleEvent(of: .value) { userSnapshot, _ in
                    defer {
                        group.leave()
                    }
                    if !userSnapshot.exists() {
                        print("No data found for friend ID \(friendID)")
                        return
                    }
                    
                    guard let userDict = userSnapshot.value as? [String: Any],
                          let userName = userDict["name"] as? String,
                          let userAvatar = userDict["avatar"] as? String else {
                        print("Failed to parse user data for friend ID: \(friendID)")
                        return
                    }
                    
                    let friendsSectionItem = FriendsSectionItem(
                        uid: friendID,
                        name: userName,
                        avatar: userAvatar
                    )
                    friendsSectionItems.append(friendsSectionItem)
                    friendsSectionItems.sort { $0.name < $1.name }
                }
            }
            
            group.notify(queue: .main) {
                completion(friendsSectionItems)
            }
        }
    }
    
    func loadInitialChatRooms(completion: @escaping ([ChatSectionItem]) -> Void) {
        guard let currentUserUID = getCurrentUserUID() else {
            completion([])
            return
        }
        
        let chatRoomsRef = databaseReference.child("chatRooms")
        chatRoomsRef.observeSingleEvent(of: .value) { (snapshot, error) in
            if let error = error {
                print("Error fetching ChatRoom \(chatRoomsRef): \(error)")
                completion([])
                return
            }
            
            guard let chatRoomsData = snapshot.value as? [String: Any] else {
                print("Failed to fetch chat rooms")
                completion([])
                return
            }
            
            var loadedChatRooms: [ChatSectionItem] = []
            let usersRef = self.databaseReference.child("users")
            
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
                            
                            self.countUnreadMessages(currentUserUID: currentUserUID, chatUID: chatRoomUID) { (unreadCount) in
                                let chatRoom = ChatSectionItem(
                                    chatUID: chatRoomUID,
                                    friendUID: friendUID,
                                    name: name,
                                    avatar: avatar,
                                    lastMessage: lastMessageText,
                                    unreadAmount: "\(unreadCount)"
                                )
                                
                                loadedChatRooms.append(chatRoom)
                                group.leave()
                            }
                        } else {
                            print("Failed to fetch user data for friendUID: \(friendUID)")
                            group.leave()
                        }
                    }
                } else {
                    print("Wrong data received")
                }
            }
            group.notify(queue: .main) {
                completion(loadedChatRooms)
            }
        }
    }
    
    func countUnreadMessages(
        currentUserUID: String,
        chatUID: String,
        completion: @escaping (Int) -> Void) {
            let databaseRef = Database.database().reference()
            let messagesRef = databaseRef.child("chatRooms").child(chatUID).child("messages")
            
            messagesRef.observeSingleEvent(of: .value) { (snapshot) in
                var unreadCount = 0
                
                for child in snapshot.children {
                    if let messageSnapshot = child as? DataSnapshot,
                       let messageData = messageSnapshot.value as? [String: Any],
                       let isRead = messageData["isRead"] as? Bool,
                       let messageOwner = messageData["messageOwner"] as? String {
                        if !isRead && messageOwner != currentUserUID {
                            unreadCount += 1
                        }
                    }
                }
                completion(unreadCount)
            }
      }
    
    func observeChatsLastMessages(completion: @escaping (String, String) -> Void) {
        let chatRoomsRef = databaseReference.child("chatRooms")
        
        chatRoomsRef.observe(.childAdded) { [weak self] snapshot in
            let chatRoomUID = snapshot.key
            self?.observeLastMessage(for: chatRoomUID, completion: completion)
        }
    }
    
    func observeLastMessage(for chatRoomUID: String, completion: @escaping (String, String) -> Void) {
        let lastMessageRef = databaseReference.child("chatRooms").child(chatRoomUID).child("chatLastMessage")
        
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
