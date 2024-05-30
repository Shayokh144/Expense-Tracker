//
//  ExpenseAnalysisViewModel.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 27/5/24.
//

import Foundation

final class ExpenseAnalysisViewModel: ObservableObject {
    
    @Published var numberOfDay: String = ""
    @Published private(set) var state: State = .loaded
    @Published var error: String = ""
    @Published var barChartUIModel: [BarChartUIModel]
    
    private var previousSelectedDays: UInt
    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    private var maxBarHeight: Double = 220.0
    
    init(
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared
    ) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        previousSelectedDays = 0
        barChartUIModel = []
    }
    
    func onChangeCurrency(newCurrency: String, dataId: String) {
        if let index = barChartUIModel.firstIndex(where: { $0.id == dataId }) {
            barChartUIModel[index].currency = newCurrency
            // TODO: UPDATE TOTAL CALCULATION
        }
    }
    
    func findAnalytics() {
        generateAnalytics(numOfDay: 0)
        return
//        state = .loading
//        error = ""
//        guard let inputNumOfDay = UInt(numberOfDay) else {
//            showError(message: "Invalid input, enter a valid integer number.")
//            return
//        }
//        guard inputNumOfDay != previousSelectedDays, inputNumOfDay != 0 else {
//            showError(message: "Result already presented, change input.")
//            return
//        }
//        if inputNumOfDay < previousSelectedDays {
//            generateAnalytics(numOfDay: inputNumOfDay)
//        } else {
//            fetchApiData(queryLimit: inputNumOfDay + 20, inputNumOfDay: inputNumOfDay)
//        }
    }
}

extension ExpenseAnalysisViewModel {
    
    enum State {
        
        case loading
        case loaded
    }
}

private extension ExpenseAnalysisViewModel {
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.error = message
            self?.state = .loaded
        }
    }
    
    func fetchApiData(queryLimit: UInt, inputNumOfDay: UInt) {
        firebaseRealtimeDBUseCase.getLatestExpenseLists(
            forAnalytics: true,
            queryLimit: queryLimit
        ) { [weak self] dataList in
            guard let self else {
                return
            }
            guard let expenseList = dataList else {
                self.showError(message: "No data found, check internet connection.")
                return
            }
            processApiData(expenseList: expenseList, numOfDay: inputNumOfDay)
        }
    }
    
    func getNthPreviousDate(from date: Date = Date(), days: Int) -> Date? {
        let calendar = Calendar.current
        let previousDate = calendar.date(byAdding: .day, value: -days, to: date)
        return previousDate
    }

    func processApiData(expenseList: [ExpenseList], numOfDay: UInt) {
        if isAllDataFound(expenseList: expenseList, numOfDay: numOfDay) {
            generateAnalytics(numOfDay: numOfDay)
            self.state = .loaded
            previousSelectedDays = numOfDay
        } else {
            fetchApiData(queryLimit: 10, inputNumOfDay: numOfDay)
        }
    }
    
    func isAllDataFound(expenseList: [ExpenseList], numOfDay: UInt) ->  Bool {
        return true
    }
    
    func generateAnalytics(numOfDay: UInt) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.barChartUIModel = [BarChartUIModel.dummyData, BarChartUIModel.dummyDat2]
        }
    }
}
