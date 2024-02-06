//
//  AppDelegate.swift
//  InshiyChat
//
//  Created by Denys Astapov on 04.12.2023.
//

import UIKit
import UserNotifications
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    static let shared = AppDelegate()
    var friendsViewController: FriendsViewController?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
                guard success else {
                    return
                }
//                print("Success in APNs registry")
            }
            application.registerForRemoteNotifications()
            
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard token != nil else {
                return
            }
//            print("Token: \(String(describing: token))")
        }
    }
}

