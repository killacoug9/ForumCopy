//
//  AppDelegate.swift
//  Forum
//
//  Created by Aaron De Guzman on 9/13/23.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupMyApp()
        requestNotificationPermission(application)
        return true
    }
    
    private func setupMyApp() {
        print("Application started up!")
    }
    
    private func requestNotificationPermission(_ application: UIApplication) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else if let error = error {
                    print("Failed to request authorization for notifications: \(error)")
                }
            }
        }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
           let token = tokenParts.joined()
           print("Device Token: \(token)")
       }

       func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("Failed to register for remote notifications: \(error)")
       }
}
