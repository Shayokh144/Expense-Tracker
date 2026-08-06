//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by nimble on 13/11/23.
//

import SwiftData
import SwiftUI

@main
struct ExpenseTrackerApp: App {

    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil {
                Text("UNIT TEST")
            } else {
                AppCoordinator(coordinator: AppCoordinatorViewModel())
            }
        }
        .modelContainer(MonthlyBudgetUseCase.shared.modelContainer)
    }
}
