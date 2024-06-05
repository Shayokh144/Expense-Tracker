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
    private var apiExpenseListCollection: [ExpenseList]
    private var savedDataKeys: [String: Bool]
    
    init(
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared
    ) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
        previousSelectedDays = 0
        barChartUIModel = []
        apiExpenseListCollection = []
        savedDataKeys = [:]
    }
    
    func onChangeCurrency(newCurrency: String, dataId: String) {
        if let index = barChartUIModel.firstIndex(where: { $0.id == dataId }) {
            let conversionRate = Constants.AppData.currencyConversionRate(
                fromCurrency: barChartUIModel[index].currency,
                toCurrency: newCurrency
            )
            barChartUIModel[index].currency = newCurrency
            barChartUIModel[index].total *= conversionRate
        }
    }
    
    func findAnalyticsSimpleVersion() {
        state = .loading
        error = ""
        guard let inputNumOfDay = UInt(numberOfDay) else {
            showError(message: "Invalid input, enter a valid integer number.")
            return
        }
        guard inputNumOfDay > previousSelectedDays, inputNumOfDay != 0 else {
            showError(message: "Result already presented, change input.")
            return
        }
        previousSelectedDays = inputNumOfDay
        fetchApiData(queryLimit: inputNumOfDay + 10, inputNumOfDay: inputNumOfDay)
        state = .loaded
    }
    
    func findAnalytics() {
        generateAnalytics(numOfDay: 0)
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
//            if previousSelectedDays == 0 {
//                // FOR THE FIRS TIME CALLING API
//                fetchApiData(queryLimit: inputNumOfDay + 20, inputNumOfDay: inputNumOfDay)
//            } else {
//                let newDays = inputNumOfDay - previousSelectedDays
//                fetchApiData(queryLimit: newDays + 20, inputNumOfDay: inputNumOfDay)
//            }
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
            saveApiData(expenseListCollection: expenseList)
            processApiData(numOfDay: inputNumOfDay)
        }
    }
    
    func saveApiData(expenseListCollection: [ExpenseList]) {
        for expenseList in expenseListCollection {
            if let listId = expenseList.id, savedDataKeys[listId] == nil {
                savedDataKeys[listId] = true
                apiExpenseListCollection.append(expenseList)
            }
        }
    }
    
    func getBarChartUIData(
        expenseListCollection: [ExpenseList],
        inputNumOfDay: UInt
    ) -> [BarChartUIModel] {
        var categoryBarUIData: [BarChartItemUIModel] = []
        var categoryContainer: [String: Double] = [:]
        var totalCost: Double = 0.0
        var categoryMaxPrice: Double = 0.0
        
        var placeBarUIData: [BarChartItemUIModel] = []
        var placeContainer: [String: Double] = [:]
        var placeMaxPrice: Double = 0.0
        
        let startDate = DateFormatter.fullDateTimeFormat.date(
            from: expenseListCollection.first?.dateTime ?? ""
        ) ?? Date()
        let endDate = DateFormatter.fullDateTimeFormat.date(
            from: expenseListCollection.last?.dateTime ?? ""
        ) ?? Date()
        let startDateString = DateFormatter.displayDateFormat.string(from: startDate)
        let endDateString = DateFormatter.displayDateFormat.string(from: endDate)
        for expenseList in expenseListCollection {
            for expense in expenseList.expenses {
                let categoryName = expense.type.lowercased().trimmingCharacters(in: .whitespaces)
                let placeName = expense.place.lowercased().trimmingCharacters(in: .whitespaces)
                let thbPrice = convertToThaiCurrency(
                    inputCurrency: expenseList.currency ?? "",
                    price: expense.price
                )
                // CATEGORY DATA
                if let oldCategoryPrice = categoryContainer[categoryName] {
                    categoryContainer[categoryName] = oldCategoryPrice + thbPrice
                } else {
                    categoryContainer[categoryName] = thbPrice
                }
                // PLACE DATA
                if let oldPlacePrice = placeContainer[placeName] {
                    placeContainer[placeName] = oldPlacePrice + thbPrice
                } else {
                    placeContainer[placeName] = thbPrice
                }
            }
            totalCost += convertToThaiCurrency(
                inputCurrency: expenseList.currency ?? "",
                price: expenseList.totalCost
            )
        }
        for (key, value) in categoryContainer {
            categoryBarUIData.append(
                BarChartItemUIModel(
                    id: key,
                    name: key,
                    actualValue: value,
                    actualCurrency: "THB",
                    mappedCurrency: "THB"
                )
            )
            categoryMaxPrice = max(categoryMaxPrice, value)
        }
        for (key, value) in placeContainer {
            placeBarUIData.append(
                BarChartItemUIModel(
                    id: key,
                    name: key,
                    actualValue: value,
                    actualCurrency: "THB",
                    mappedCurrency: "THB"
                )
            )
            placeMaxPrice = max(placeMaxPrice, value)
        }
        categoryBarUIData = categoryBarUIData.sorted { $0.actualValue > $1.actualValue }
        let categoryBarChartUIData = BarChartUIModel(
            id: UUID().uuidString,
            graphType: .categoryBar,
            name: "Data based on Category for last \(inputNumOfDay) days",
            startDate: endDateString,
            endDate: startDateString,
            total: totalCost,
            currency: "THB",
            chartData: categoryBarUIData,
            barItemMaxValue: categoryMaxPrice
        )
        placeBarUIData = placeBarUIData.sorted { $0.actualValue > $1.actualValue }
        let placeBarChartUIData = BarChartUIModel(
            id: UUID().uuidString, 
            graphType: .locationBar,
            name: "Data based on Place for last \(inputNumOfDay) days",
            startDate: endDateString,
            endDate: startDateString,
            total: totalCost,
            currency: "THB",
            chartData: placeBarUIData,
            barItemMaxValue: placeMaxPrice
        )
        return [categoryBarChartUIData, placeBarChartUIData]
    }
    
    func convertToThaiCurrency(inputCurrency: String, price: Double) -> Double {
        if inputCurrency == "BDT" {
            return price / 3.2
        } else if inputCurrency == "USD" {
            return price * 36.8
        }
        return price
    }
    
    func getNthPreviousDate(from date: Date = Date(), days: Int) -> Date? {
        let calendar = Calendar.current
        let previousDate = calendar.date(byAdding: .day, value: -days, to: date)
        return previousDate
    }

    func processApiData(numOfDay: UInt) {
        // SIMPLE VERSION
        generateAnalytics(numOfDay: numOfDay)
//        if isAllDataFound(numOfDay: numOfDay) {
//            generateAnalytics(numOfDay: numOfDay)
//            self.state = .loaded
//            previousSelectedDays = numOfDay
//        } else {
//            fetchApiData(queryLimit: 10, inputNumOfDay: numOfDay)
//        }
    }
    
    func isAllDataFound(numOfDay: UInt) ->  Bool {
        return true
    }
    
    func generateAnalytics(numOfDay: UInt) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            barChartUIModel = getBarChartUIData(
                expenseListCollection: apiExpenseListCollection,
                inputNumOfDay: numOfDay
            )
        }
    }
}
