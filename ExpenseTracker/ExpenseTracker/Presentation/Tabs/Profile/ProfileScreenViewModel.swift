//
//  ProfileScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 19/12/23.
//

import Combine
import Foundation

@MainActor
final class ProfileScreenViewModel: ObservableObject {

    private let loginGmailUseCase: LoginGmailUseCaseProtocol
    private let monthlyBudgetUseCase: MonthlyBudgetUseCase
    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    let user: User
    private var cancellable = Set<AnyCancellable>()
    @Published var authState: AuthState = .signedIn
    @Published var budgetAmount: String = ""
    @Published var selectedCurrency: String
    @Published var selectedDate = Date.now
    @Published var isShowingAlert = false
    @Published var isUpdateBudgetVisible = false
    @Published var isBudgetExpenseSheetPresented = false
    @Published private(set) var isSaveSuccess = false
    @Published private(set) var hasCurrentMonthBudget = false
    @Published private(set) var budgetProgressUIModel: BudgetProgressUIModel?
    @Published private(set) var budgetExpenseItems: [BudgetExpenseItemUIModel] = []

    private let monthlyExpenseQueryLimit: UInt = 60
    private var budgetProgressRequestId = UUID()
    private var currentMonthBudgetAmount: Double = 0
    private var currentMonthBudgetCurrency: String = "THB"

    var alertData: AlertUIModel {
        if isSaveSuccess {
            return .init(
                title: "Success!",
                description: Constants.AppText.budgetSaveSuccess,
                isError: false
            )
        }
        return .init(
            title: "Error!",
            description: budgetAmount.isEmpty ?
            Constants.AppText.budgetInvalidAmount :
            Constants.AppText.budgetSaveFailed,
            isError: true
        )
    }

    init(
        user: User,
        loginGmailUseCase: LoginGmailUseCaseProtocol = LoginGmailUseCase(),
        monthlyBudgetUseCase: MonthlyBudgetUseCase = .shared,
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = .shared
    ) {
        self.user = user
        self.loginGmailUseCase = loginGmailUseCase
        self.monthlyBudgetUseCase = monthlyBudgetUseCase
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        selectedCurrency = Constants.AppData.currencyList.first ?? "THB"
        loadBudgetForSelectedMonth()
    }

    func onAppear() {
        loadBudgetProgress()
    }

    func onTapSignOut() {
        do {
            try loginGmailUseCase.signOut()
            authState = .signedOut
        } catch let error {
            authState = .error(message: error.localizedDescription)
        }
    }

    func showBudgetSection() {
        isUpdateBudgetVisible = true
        selectedDate = .now
        loadBudgetForSelectedMonth()
    }

    func onTapUpdateBudget() {
        isUpdateBudgetVisible = true
        selectedDate = .now
        loadBudgetForSelectedMonth()
    }

    func onTapViewBudgetExpenses() {
        isBudgetExpenseSheetPresented = true
    }

    func onDismissBudgetExpenseSheet() {
        recalculateBudgetProgressFromSelectedItems()
        isBudgetExpenseSheetPresented = false
    }

    func onToggleBudgetExpenseItem(id: String) {
        guard let index = budgetExpenseItems.firstIndex(where: { $0.id == id }) else {
            return
        }
        var updatedItems = budgetExpenseItems
        updatedItems[index].isSelected.toggle()
        budgetExpenseItems = updatedItems
        recalculateBudgetProgressFromSelectedItems()
    }

    func onSelectedDateChanged() {
        loadBudgetForSelectedMonth()
    }

    func onTapSaveBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else {
            isSaveSuccess = false
            isShowingAlert = true
            return
        }

        do {
            try monthlyBudgetUseCase.saveBudget(
                amount: amount,
                currency: selectedCurrency,
                date: selectedDate
            )
            isSaveSuccess = true
            isShowingAlert = true
            isUpdateBudgetVisible = false
            applySavedBudgetToProgress(amount: amount)
        } catch {
            isSaveSuccess = false
            isShowingAlert = true
        }
    }

    private var isSelectedDateCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.isDate(selectedDate, equalTo: .now, toGranularity: .month)
    }

    private func applySavedBudgetToProgress(amount: Double) {
        if isSelectedDateCurrentMonth {
            let spentAmount = budgetProgressUIModel?.spentAmount ?? 0
            budgetProgressUIModel = BudgetProgressUIModel(
                remainingAmount: max(amount - spentAmount, 0),
                spentAmount: spentAmount,
                budgetAmount: amount,
                currency: selectedCurrency
            )
            loadBudgetProgress()
        } else {
            refreshCurrentMonthBudgetProgress()
        }
    }

    private func refreshCurrentMonthBudgetProgress() {
        let components = Calendar.current.dateComponents(
            [.month, .year],
            from: .now
        )
        guard let month = components.month, let year = components.year else {
            hasCurrentMonthBudget = false
            budgetProgressUIModel = nil
            return
        }
        updateBudgetProgress(month: month, year: year)
    }

    private func updateBudgetProgress(month: Int, year: Int) {
        guard let budget = monthlyBudgetUseCase.fetchBudget(month: month, year: year) else {
            hasCurrentMonthBudget = false
            budgetProgressUIModel = nil
            budgetExpenseItems = []
            return
        }

        hasCurrentMonthBudget = true
        currentMonthBudgetAmount = budget.amount
        currentMonthBudgetCurrency = budget.currency
        let requestId = UUID()
        budgetProgressRequestId = requestId
        let yearMonthKey = yearMonthKey(month: month, year: year)
        let previousSpent = budgetProgressUIModel?.spentAmount ?? 0

        budgetProgressUIModel = BudgetProgressUIModel(
            remainingAmount: max(budget.amount - previousSpent, 0),
            spentAmount: previousSpent,
            budgetAmount: budget.amount,
            currency: budget.currency
        )

        firebaseRealtimeDBUseCase.getRecentExpenseLists(
            queryLimit: monthlyExpenseQueryLimit
        ) { [weak self] dataList in
            Task { @MainActor in
                guard let self, self.budgetProgressRequestId == requestId else { return }
                guard let currentBudget = self.monthlyBudgetUseCase.fetchBudget(
                    month: month,
                    year: year
                ) else { return }

                self.currentMonthBudgetAmount = currentBudget.amount
                self.currentMonthBudgetCurrency = currentBudget.currency
                let expenseItems = self.buildBudgetExpenseItems(
                    from: dataList ?? [],
                    yearMonthKey: yearMonthKey,
                    budgetCurrency: currentBudget.currency
                )
                self.budgetExpenseItems = self.mergeExpenseItemSelections(
                    newItems: expenseItems
                )
                self.recalculateBudgetProgressFromSelectedItems()
            }
        }
    }

    func loadBudgetProgress() {
        let components = Calendar.current.dateComponents(
            [.month, .year],
            from: .now
        )
        guard let month = components.month, let year = components.year else {
            hasCurrentMonthBudget = false
            budgetProgressUIModel = nil
            return
        }

        updateBudgetProgress(month: month, year: year)
    }

    private func yearMonthKey(month: Int, year: Int) -> String {
        String(format: "%04d-%02d", year, month)
    }

    private func loadBudgetForSelectedMonth() {
        let components = Calendar.current.dateComponents(
            [.month, .year],
            from: selectedDate
        )
        guard let month = components.month, let year = components.year else {
            return
        }

        if let budget = monthlyBudgetUseCase.fetchBudget(month: month, year: year) {
            budgetAmount = budget.amount.fractionTwoDigitString
            selectedCurrency = budget.currency
            selectedDate = budget.budgetDate
        } else {
            budgetAmount = ""
            selectedCurrency = Constants.AppData.currencyList.first ?? "THB"
        }
    }

    func recalculateBudgetProgressFromSelectedItems() {
        guard hasCurrentMonthBudget else { return }

        let spentAmount = budgetExpenseItems
            .filter(\.isSelected)
            .reduce(0.0) { $0 + $1.cost }

        budgetProgressUIModel = BudgetProgressUIModel(
            remainingAmount: max(currentMonthBudgetAmount - spentAmount, 0),
            spentAmount: spentAmount,
            budgetAmount: currentMonthBudgetAmount,
            currency: currentMonthBudgetCurrency
        )
    }

    private func buildBudgetExpenseItems(
        from expenseLists: [ExpenseList],
        yearMonthKey: String,
        budgetCurrency: String
    ) -> [BudgetExpenseItemUIModel] {
        expenseLists
            .filter { $0.dateTime.yearMonthKey == yearMonthKey }
            .flatMap { expenseList in
                let listId = expenseList.id ?? expenseList.dateTime
                let expenseCurrency = expenseList.currency ?? "THB"
                let conversionRate = Constants.AppData.currencyConversionRate(
                    fromCurrency: expenseCurrency,
                    toCurrency: budgetCurrency
                )
                return expenseList.expenses.enumerated().map { index, expense in
                    BudgetExpenseItemUIModel(
                        id: "\(listId)-\(index)-\(expense.name)-\(expense.price)",
                        name: expense.name,
                        cost: expense.price * conversionRate,
                        isSelected: true
                    )
                }
            }
    }

    private func mergeExpenseItemSelections(
        newItems: [BudgetExpenseItemUIModel]
    ) -> [BudgetExpenseItemUIModel] {
        let selectionMap = Dictionary(
            uniqueKeysWithValues: budgetExpenseItems.map { ($0.id, $0.isSelected) }
        )
        return newItems.map { item in
            var updatedItem = item
            if let isSelected = selectionMap[item.id] {
                updatedItem.isSelected = isSelected
            }
            return updatedItem
        }
    }
}
