//
//  ExpenseHistoryDetailsViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 17/4/24.
//

import Foundation

final class ExpenseHistoryDetailsViewModel: ObservableObject {

    @Published private(set) var expenseList: ExpenseList?
    @Published private(set) var state: State = .viewing
    @Published private(set) var isSaving = false
    @Published private(set) var didDeleteList = false
    @Published private(set) var isOperationSuccess = false
    @Published var isShowingAlert = false
    @Published var isShowingDeleteListConfirmation = false
    @Published var isShowingDeleteItemConfirmation = false

    @Published var editName: String = ""
    @Published var editPrice: String = ""
    @Published var editType: String = ""
    @Published var editPlace: String = ""
    @Published var editCountry: String = ""
    @Published var editCity: String = ""

    private let id: String
    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    private let onExpenseListDeleted: ((String) -> Void)?
    private let onExpenseListUpdated: ((ExpenseList) -> Void)?
    private var pendingDeleteExpense: Expense?
    private var alertDescription = ""

    var alertData: AlertUIModel {
        .init(
            title: isOperationSuccess ? "Success!" : "Error!",
            description: alertDescription,
            isError: !isOperationSuccess
        )
    }

    init(
        id: String,
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared,
        onExpenseListDeleted: ((String) -> Void)? = nil,
        onExpenseListUpdated: ((ExpenseList) -> Void)? = nil
    ) {
        self.id = id
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        self.onExpenseListDeleted = onExpenseListDeleted
        self.onExpenseListUpdated = onExpenseListUpdated
    }

    func loadData() {
        firebaseRealtimeDBUseCase.getExpenseList(id: id) { [weak self] data in
            DispatchQueue.main.async {
                self?.expenseList = data
            }
        }
    }

    func onTapEditButton(expense: Expense) {
        editName = expense.name
        editPrice = expense.price.fractionTwoDigitString
        editType = expense.type
        editPlace = expense.place
        editCity = expense.city
        editCountry = expense.country
        state = .editing(expense)
    }

    func onCancelEdit() {
        state = .viewing
    }

    func onSaveEditExpense(expense: Expense) {
        guard let expenseList = expenseList else { return }
        guard let editIndex = expenseList.expenses.firstIndex(where: {
            matches(expense: $0, other: expense)
        }) else {
            return
        }

        var updatedExpenses = expenseList.expenses
        updatedExpenses[editIndex].name = editName
        updatedExpenses[editIndex].price = Double(editPrice) ?? 0.0
        updatedExpenses[editIndex].type = editType
        updatedExpenses[editIndex].place = editPlace
        updatedExpenses[editIndex].city = editCity
        updatedExpenses[editIndex].country = editCountry

        let updatedList = expenseList.updating(expenses: updatedExpenses)
        persistUpdatedList(
            updatedList,
            successMessage: Constants.AppText.expenseUpdateSuccess,
            failureMessage: Constants.AppText.expenseUpdateFailed
        )
    }

    func onTapDeleteItem(expense: Expense) {
        pendingDeleteExpense = expense
        isShowingDeleteItemConfirmation = true
    }

    func confirmDeleteItem() {
        guard let expense = pendingDeleteExpense else { return }
        pendingDeleteExpense = nil
        isShowingDeleteItemConfirmation = false

        guard let expenseList = expenseList else { return }
        let updatedExpenses = expenseList.expenses.filter {
            !matches(expense: $0, other: expense)
        }

        if updatedExpenses.isEmpty {
            deleteExpenseList()
            return
        }

        let updatedList = expenseList.updating(expenses: updatedExpenses)
        persistUpdatedList(
            updatedList,
            successMessage: Constants.AppText.expenseDeleteSuccess,
            failureMessage: Constants.AppText.expenseDeleteFailed
        )
    }

    func onTapDeleteList() {
        isShowingDeleteListConfirmation = true
    }

    func confirmDeleteList() {
        isShowingDeleteListConfirmation = false
        deleteExpenseList()
    }

    private func deleteExpenseList() {
        isSaving = true
        firebaseRealtimeDBUseCase.deleteExpenseList(id: id) { [weak self] isSuccess in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                if isSuccess {
                    self.onExpenseListDeleted?(self.id)
                    self.didDeleteList = true
                } else {
                    self.showAlert(
                        isSuccess: false,
                        description: Constants.AppText.expenseDeleteFailed
                    )
                }
            }
        }
    }

    private func persistUpdatedList(
        _ updatedList: ExpenseList,
        successMessage: String,
        failureMessage: String
    ) {
        isSaving = true
        firebaseRealtimeDBUseCase.updateExpenseList(expenseList: updatedList) { [weak self] isSuccess in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                if isSuccess {
                    self.expenseList = updatedList
                    self.state = .viewing
                    self.onExpenseListUpdated?(updatedList)
                    self.showAlert(isSuccess: true, description: successMessage)
                } else {
                    self.showAlert(isSuccess: false, description: failureMessage)
                }
            }
        }
    }

    private func showAlert(isSuccess: Bool, description: String) {
        isOperationSuccess = isSuccess
        alertDescription = description
        isShowingAlert = true
    }

    private func matches(expense: Expense, other: Expense) -> Bool {
        if let expenseId = expense.id, let otherId = other.id {
            return expenseId == otherId
        }
        return expense == other
    }
}

extension ExpenseHistoryDetailsViewModel {

    enum State: Equatable {
        case viewing
        case editing(Expense)
    }
}
