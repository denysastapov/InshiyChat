//
//  HomeViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 12.12.2023.
//

import Foundation
import Firebase

class FriendsViewModel {
    
    func getCurrentUserUID() -> String? {
        
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        } else {
            return nil
        }
    }
    
    func fetchFriends(completion: @escaping ([FriendsSectionItem]) -> Void) {
        guard let currentUserUID = getCurrentUserUID() else {
            print("No current user UID found")
            completion([])
            return
        }
        
        let databaseReference = Database.database().reference()
        
        databaseReference.child("users").child(currentUserUID).child("friendIDs").observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching data for friend IDs: \(error)")
                completion([])
                return
            }
            
            if !snapshot.exists() {
                print("No friend IDs found for user: \(currentUserUID)")
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
                
                databaseReference.child("users").child(friendID).observeSingleEvent(of: .value) { userSnapshot, _ in
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
}
