//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by nimble on 13/11/23.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppCoordinator(coordinator: AppCoordinatorViewModel())
        }
    }
}
