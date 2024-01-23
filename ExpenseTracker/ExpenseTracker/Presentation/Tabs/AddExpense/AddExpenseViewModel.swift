//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Combine
import Foundation

final class AddExpenseViewModel: ObservableObject {

    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    let currencyList: [String] = ["BDT", "THB", "USD"]
    @Published private(set) var addedLocalExpenseList: [Expense]
    @Published private(set) var currentTotal: Double
    @Published private(set) var state: State
    @Published var selectedCurrency: String
    @Published var selectedDate = Date.now

    @Published var editName: String = ""
    @Published var editPrice: String = ""
    @Published var editType: String = ""
    @Published var editPlace: String = ""
    @Published var editCountry: String = ""
    @Published var editCity: String = ""
    @Published var isShowingAlert: Bool = false
    @Published private(set) var isDataAddSuccess = false

    var alertData: AlertUIModel {
        let title = isDataAddSuccess ? "Success!" : "Error!"
        let description = isDataAddSuccess ?
        "Expense list added successfully." :
        "Failed to add expense list"
        return .init(
            title: title,
            description: description,
            isError: !isDataAddSuccess
        )
    }

    init(firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        addedLocalExpenseList = []
        currentTotal = 0.0
        state = .add
        selectedCurrency = currencyList.first ?? "BDT"
    }

    func saveExpenseList() {
        if !addedLocalExpenseList.isEmpty {
            let expenseList = createExpenseList()
            firebaseRealtimeDBUseCase.postExpanse(
                expenseList: expenseList
            ) { [weak self] isSuccess in
                NSLog("XYZ POST RESULT: \(isSuccess)")
                self?.isDataAddSuccess = isSuccess
                if isSuccess {
                    self?.addedLocalExpenseList.removeAll()
                }
                self?.isShowingAlert = true
            }
        }
    }

    func onAddLocalExpense(expense: Expense) {
        addedLocalExpenseList.append(expense)
        currentTotal = addedLocalExpenseList.map(\.price).reduce(0.0, +)
    }

    func onTapEditButton(expense: Expense) {
        editName = expense.name
        editPrice = expense.price.fractionTwoDigitString
        editType = expense.type
        editPlace = expense.place
        editCity = expense.city
        editCountry = expense.country
        state = .edit(expense)
    }

    func onSaveEditExpense(expense: Expense) {
        if let editIndex = addedLocalExpenseList.firstIndex(where: { $0.id == expense.id }) {
            addedLocalExpenseList[editIndex].name = editName
            addedLocalExpenseList[editIndex].price = Double(editPrice) ?? 0.0
            addedLocalExpenseList[editIndex].type = editType
            addedLocalExpenseList[editIndex].place = editPlace
            addedLocalExpenseList[editIndex].city = editCity
            addedLocalExpenseList[editIndex].country = editCountry
        }
        currentTotal = addedLocalExpenseList.map(\.price).reduce(0.0, +)
        state = .add
    }

    private func createExpenseList() -> ExpenseList {
        let dateTime = DateFormatter.fullDateTimeFormat.string(from: selectedDate)
        let country = addedLocalExpenseList.first?.country ?? "Unknown"
        return .init(
            dateTime: dateTime,
            totalCost: currentTotal,
            country: country,
            currency: selectedCurrency,
            expenses: addedLocalExpenseList
        )
    }
}

extension AddExpenseViewModel {

    enum State {
        case add
        case edit(Expense)
    }
}
