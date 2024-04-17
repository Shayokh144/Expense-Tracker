//
//  AppDelegate.swift
//  ExpenseTracker
//
//  Created by Taher on 29/11/23.
//

import FirebaseCore
import FirebaseDatabase
import GoogleSignIn
import SwiftUI


final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        NSLog("UIApplication url: \(url)")
        return GIDSignIn.sharedInstance.handle(url)
    }
}
