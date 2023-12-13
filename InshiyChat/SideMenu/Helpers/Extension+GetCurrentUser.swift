//
//  Extension+GetCurrentUser.swift
//  InshiyChat
//
//  Created by Denys Astapov on 11.12.2023.
//

import UIKit
import Firebase

extension HomeViewController {
    
    func getCurrentUser() {
        
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not autorized")
            return
        }
        
        let userId = currentUser.uid
        let database = Database.database()
        let usersReference = database.reference().child("users")
        
        usersReference.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userData = snapshot.value as? [String: Any] {
                if let name = userData["name"] as? String {
                    self.sideMenuViewController.userFirstNameLabel.text = name
                }
                
                if let avatar = userData["avatar"] as? String {
                    if let avatarURL = URL(string: avatar) {
                        let task = URLSession.shared.dataTask(with: avatarURL) { (data, response, error) in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.sideMenuViewController.userAvatarImageView.image = image
                                }
                            } else {
                                print("Can't load image")
                            }
                        }
                        task.resume()
                    } else {
                        print("URL is not valid")
                        self.sideMenuViewController.userAvatarImageView.image = UIImage(named: "profile_def")
                    }
                }
                
                if let phone = userData["phone"] as? String {
                    self.sideMenuViewController.userPhoneNumberLabel.text = phone
                }
                
                if let username = userData["username"] as? String {
                    self.sideMenuViewController.userNameLabel.text = username
                }
            }
        }) { (error) in
            print("Error reciving userdata: \(error.localizedDescription)")
        }
        
    }
    
}
