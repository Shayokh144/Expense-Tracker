//
//  TabScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct TabScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @StateObject private var addExpenseViewModel: AddExpenseViewModel
    @StateObject private var expenseHistoryViewModel: ExpenseHistoryViewModel
    @StateObject private var expenseAnalysisViewModel: ExpenseAnalysisViewModel
    @StateObject private var profileScreenViewModel: ProfileScreenViewModel
    
    private let user: User

    var body: some View {
        TabView {
            AddExpenseScreen(viewModel: addExpenseViewModel)
                .tabItem {
                    Label(Constants.AppText.tabAdd, systemImage: "note.text.badge.plus")
                }
            ExpenseHistoryScreen(viewModel: expenseHistoryViewModel)
                .tabItem {
                    Label(Constants.AppText.tabHistory, systemImage: "list.bullet.rectangle")
                }
            ExpenseAnalysisScreen(viewModel: expenseAnalysisViewModel)
                .tabItem {
                    Label(Constants.AppText.tabAnalysis, systemImage: "chart.bar.xaxis")
                }
            ProfileScreen(
                viewModel: profileScreenViewModel,
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
        _addExpenseViewModel = StateObject(wrappedValue: AddExpenseViewModel())
        _expenseHistoryViewModel = StateObject(wrappedValue: ExpenseHistoryViewModel())
        _expenseAnalysisViewModel = StateObject(wrappedValue: ExpenseAnalysisViewModel())
        _profileScreenViewModel = StateObject(wrappedValue: ProfileScreenViewModel(user: user))
    }
}
