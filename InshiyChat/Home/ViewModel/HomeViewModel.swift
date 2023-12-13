//
//  HomeViewModel.swift
//  InshiyChat
//
//  Created by Denys Astapov on 12.12.2023.
//

import UIKit
import Firebase

class HomeViewModel {
    
    func fetchChatRooms(completion: @escaping ([HomeSectionItem]) -> Void) {
        let databaseReference = Database.database().reference()
        
        databaseReference.child("users").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() {
                if let userDictionary = snapshot.value as? [String: Any] {
                    var homeSectionItems: [HomeSectionItem] = []
                    
                    for (_, userData) in userDictionary {
                        if let userDictionary = userData as? [String: Any] {
                            let userName = userDictionary["name"] as? String ?? ""
                            let userAvatar = userDictionary["avatar"] as? String ?? ""
                            
                            let homeSectionItem = HomeSectionItem(
                                name: userName,
                                avatar: userAvatar
                            )
                            homeSectionItems.append(homeSectionItem)
                        }
                    }
                    completion(homeSectionItems)
                } else {
                    completion([])
                    print("Failed to parse userDict")
                }
            } else {
                completion([])
                print("Snapshot does not exist")
            }
        }
    }
}

struct HomeSection: Hashable {
    let id = UUID()
    let items: [HomeSectionItem]
}

struct HomeSectionItem: Hashable {
    let id = UUID()
    let name: String
    let avatar: String
}
