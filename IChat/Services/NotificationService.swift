//
//  NotificationService.swift
//  IChat
//
//  Created by macbook on 14.04.2023.
//

import UIKit

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    // MARK: Enum
    
    enum NameSapaces: String {
        case title = "IChat"
        case localIdentifier = "Local Notification"
    }
    
    // MARK: - Properties
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Methods
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
    
    // MARK: - Push
    
    func push(_ message: String, title: String = NameSapaces.title.rawValue) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "Local"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: NameSapaces.localIdentifier.rawValue, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
