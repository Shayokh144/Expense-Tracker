//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by nimble on 13/11/23.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreen(
                viewModel: HomeViewModel()
            )
        }
    }
}
