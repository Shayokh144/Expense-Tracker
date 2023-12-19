//
//  TabScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct TabScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    private let user: User

    var body: some View {
        TabView {
            AddExpenseScreen()
                .tabItem {
                    Label(Constants.AppText.tabAdd, systemImage: "note.text.badge.plus")
                }
            ExpenseHistoryScreen()
                .tabItem {
                    Label(Constants.AppText.tabHistory, systemImage: "list.bullet.rectangle")
                }
            ExpenseAnalysisScreen()
                .tabItem {
                    Label(Constants.AppText.tabAnalysis, systemImage: "chart.bar.xaxis")
                }
            ProfileScreen(
                viewModel: ProfileScreenViewModel(user: user),
                onSignOutSuccess: {
                    navigator.goToHome()
                }
            )
            .tabItem {
                Label(Constants.AppText.tabProfile, systemImage: "person.crop.circle.fill")
            }
        }
        .tint(Color(hexString: Constants.AppColors.tabSelectionColor))
        .environmentObject(navigator)
    }

    init(user: User) {
        self.user = user
    }
}
