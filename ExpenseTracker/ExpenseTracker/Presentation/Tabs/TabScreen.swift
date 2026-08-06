//
//  TabScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct TabScreen: View {

    private enum TabItem: Int {
        case add = 0
        case history = 1
        case analysis = 2
        case profile = 3
    }

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @StateObject private var addExpenseViewModel: AddExpenseViewModel
    @StateObject private var expenseHistoryViewModel: ExpenseHistoryViewModel
    @StateObject private var expenseAnalysisViewModel: ExpenseAnalysisViewModel
    @StateObject private var profileScreenViewModel: ProfileScreenViewModel

    @State private var selectedTab = TabItem.add.rawValue
    @State private var isShowingBudgetAlert = false

    private let user: User
    private let monthlyBudgetUseCase: MonthlyBudgetUseCase

    var body: some View {
        TabView(selection: $selectedTab) {
            AddExpenseScreen(viewModel: addExpenseViewModel)
                .tabItem {
                    Label(Constants.AppText.tabAdd, systemImage: "note.text.badge.plus")
                }
                .tag(TabItem.add.rawValue)
            ExpenseHistoryScreen(viewModel: expenseHistoryViewModel)
                .tabItem {
                    Label(Constants.AppText.tabHistory, systemImage: "list.bullet.rectangle")
                }
                .tag(TabItem.history.rawValue)
            ExpenseAnalysisScreen(viewModel: expenseAnalysisViewModel)
                .tabItem {
                    Label(Constants.AppText.tabAnalysis, systemImage: "chart.bar.xaxis")
                }
                .tag(TabItem.analysis.rawValue)
            ProfileScreen(
                viewModel: profileScreenViewModel,
                onSignOutSuccess: {
                    navigator.goToHome()
                }
            )
            .tabItem {
                Label(Constants.AppText.tabProfile, systemImage: "person.crop.circle.fill")
            }
            .tag(TabItem.profile.rawValue)
        }
        .tint(Color(hexString: Constants.AppColors.tabSelectionColor))
        .environmentObject(navigator)
        .onAppear {
            checkMonthlyBudget()
        }
        .alert(
            Constants.AppText.budgetAlertTitle,
            isPresented: $isShowingBudgetAlert
        ) {
            Button(Constants.AppText.cancel, role: .cancel) { }
            Button(Constants.AppText.setBudget) {
                selectedTab = TabItem.profile.rawValue
                profileScreenViewModel.showBudgetSection()
            }
        } message: {
            Text(Constants.AppText.budgetAlertMessage)
        }
    }

    init(
        user: User,
        monthlyBudgetUseCase: MonthlyBudgetUseCase = .shared
    ) {
        self.user = user
        self.monthlyBudgetUseCase = monthlyBudgetUseCase
        _addExpenseViewModel = StateObject(wrappedValue: AddExpenseViewModel())
        _expenseHistoryViewModel = StateObject(wrappedValue: ExpenseHistoryViewModel())
        _expenseAnalysisViewModel = StateObject(wrappedValue: ExpenseAnalysisViewModel())
        _profileScreenViewModel = StateObject(wrappedValue: ProfileScreenViewModel(user: user))
    }

    private func checkMonthlyBudget() {
        if !monthlyBudgetUseCase.hasBudgetForCurrentMonth() {
            isShowingBudgetAlert = true
        }
    }
}
