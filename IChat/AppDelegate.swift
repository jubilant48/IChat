//
//  AppDelegate.swift
//  IChat
//
//  Created by macbook on 14.12.2022.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properies
    
    let notificationService = NotificationService()
    
    var activeChatsListener: ListenerRegistration?
    var waitingChatsListener: ListenerRegistration?
    
    // MARK: - Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        notificationService.requestAutorization()
        notificationService.notificationCenter.delegate = notificationService
        
        if Auth.auth().currentUser != nil {
            addActiveChatsListener()
            addWaitingChatsListener()
        }
        
        return true
    }

    // MARK: - UISceneSession Life cycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
          return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Adding listeners service

extension AppDelegate {
    func addActiveChatsListener() {
        activeChatsListener = ListenerService.shared.activeChatsObserve(chats: []) { isSendPushNotification, chat in
            if isSendPushNotification {
                self.notificationService.push(chat.lastMessageContent, title: chat.friendUsername)
            }
        } completion: { _ in }
    }
    
    func addWaitingChatsListener() {
        waitingChatsListener = ListenerService.shared.waitingChatsObserve(chats: []) { chat in
            self.notificationService.push("\(chat.friendUsername) invited you to chat!")
        } completion: { _ in }
    }
}

