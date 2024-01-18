//
//  AppDelegate.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = AppDelegate()
    var friendsViewController: FriendsViewController?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

