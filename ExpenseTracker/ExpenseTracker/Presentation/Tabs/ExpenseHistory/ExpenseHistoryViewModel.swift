//
//  ExpenseHistoryViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 16/1/24.
//

import Combine
import Foundation

final class ExpenseHistoryViewModel: ObservableObject {

    @Published private(set) var state: State
    @Published private(set) var totalExpense: Double
    @Published private(set) var uiExpenseList: [ExpenseHistoryItemUIModel]
    @Published var startDate = Date.now {
        didSet {
            if isFilterOn {
                updateUIData()
            }
        }
    }

    @Published var endDate = Date.now {
        didSet {
            if isFilterOn {
                updateUIData()
            }
        }
    }

    @Published var isFilterOn = false {
        didSet {
            updateUIData()
        }
    }

    private var expenseHistoryItems: [ExpenseHistoryItemUIModel]
    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    
    init(
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared
    ) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        state = .idle
        expenseHistoryItems = []
        uiExpenseList = []
        totalExpense = 0.0
    }

//    func loadExpenseData() {
//        state = .loading
//        firebaseRealtimeDBUseCase.getExpenses { expenseList in
//            if let expenseList = expenseList {
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else {
//                        return
//                    }
//                    if !self.expenseHistoryItems.contains(where: { $0.id == expenseList.id }) {
//                        self.populateUIList(expenseList: expenseList)
//                    }
//                    self.expenseHistoryItems = self.expenseHistoryItems.sorted { (item1, item2) -> Bool in
//                        return item1.dateTime > item2.dateTime
//                    }
//                    calculateTotal()
//                    state = .loaded
//                    print("expenseHistoryItems cnt: \(expenseHistoryItems.count)")
//                }
//            }
//        }
//    }

    func loadExpenseData() {
        state = .loading
        firebaseRealtimeDBUseCase.getLatestExpenseLists(
            queryLimit: 10
        ) {  expenseList in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                if let expenses = expenseList {
                    for expense in expenses {
                        if !self.expenseHistoryItems.contains(where: { $0.id == expense.id }) {
                            self.populateUIList(expenseList: expense)
                        }
                    }
                    self.expenseHistoryItems = self.expenseHistoryItems.sorted { (item1, item2) -> Bool in
                        return item1.dateTime > item2.dateTime
                    }
                    updateUIData()
//                    print("expenseHistoryItems cnt: \(expenseHistoryItems.count)")
                }
                self.state = .loaded
            }
        }
    }

    private func updateUIData() {
        if state != .loading {
            state = .loading
        }
        if isFilterOn {
            uiExpenseList.removeAll()
            filterDataWithDate()
        } else {
            uiExpenseList = expenseHistoryItems
        }
        calculateTotal()
        state = .loaded
    }

    private func filterDataWithDate() {
        uiExpenseList = expenseHistoryItems.filter {
            let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.dateTime)
            let fromDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
            let toDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            if let currentDate = Calendar.current.date(from: currentDateComponents),
                let fromDate = Calendar.current.date(from: fromDateComponents),
                let toDate = Calendar.current.date(from: toDateComponents) {

                if fromDate <= currentDate && currentDate <= toDate {
                    return true
                }
            }
            return false
        }
    }

    private func calculateTotal() {
        let uniqueCurrencies = Set(uiExpenseList.map { $0.currency })
        var cost: Double = 0.0
        for currency in uniqueCurrencies {
            cost += getCostInBdt(from: currency)
        }
        totalExpense = cost
    }

    private func getCostInBdt(from currency: String) -> Double {
        let expenses = uiExpenseList.filter {
            getCurrency(for: $0.currency, country: $0.country) == currency
        }
        let cost = expenses.reduce(0) { result, item in
            result + (Double(item.totalCost) ?? 0.0)
        }
        if currency == "THB" {
            return cost * 3.2
        } else if currency == "USD" {
            return cost * 121.0
        }
        return cost
    }

    private func populateUIList(expenseList: ExpenseList) {
        let mostExpensiveItemName = expenseList.expenses.max(by: { $0.price < $1.price })?.name
        let date: Date = DateFormatter.fullDateTimeFormat.date(from: expenseList.dateTime) ?? Date()
        let dateTimeString = DateFormatter.displayDateTimeFormat.string(from: date)
        let uiModel = ExpenseHistoryItemUIModel(
            id: expenseList.id ?? expenseList.dateTime,
            mostExpensiveItemName: mostExpensiveItemName ?? "Unknown",
            itemCount: expenseList.expenses.count,
            totalCost: expenseList.totalCost.fractionTwoDigitString,
            dateTimeString: dateTimeString,
            currency: getCurrency(for: expenseList.currency, country: expenseList.country),
            country: expenseList.country,
            dateTime: date
        )
        self.expenseHistoryItems.append(uiModel)
    }

    private func getCurrency(for currency: String?, country: String) -> String {
        if let currency = currency {
            return currency
        }
        if country == "Thailand" {
            return "THB"
        } else if country == "Bangladesh" {
            return "BDT"
        }
        return "USD"
    }
}

extension ExpenseHistoryViewModel {

    enum State {
        case idle
        case loading
        case loaded
    }
}
