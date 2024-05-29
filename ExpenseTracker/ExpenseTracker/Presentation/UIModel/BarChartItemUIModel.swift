//
//  BarChartItemUIModel.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 29/5/24.
//

import Foundation

struct BarChartItemUIModel: Identifiable {

    let id: String
    let name: String // can be location name, product name, category name
    let actualValue: Double
    let actualCurrency: String
    var mappedCurrency: String
    
    func getMappedValue(maxValue: Double, maxAvailableSpace: Double) -> Double {
        return (maxAvailableSpace / maxValue) * actualValue
    }
}

extension BarChartItemUIModel {
    
    static let dummyData: [BarChartItemUIModel] = [
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Transport",
            actualValue: 150.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Grocery",
            actualValue: 80.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Wearing",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Electronics",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Entertainment",
            actualValue: 60.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Utility",
            actualValue: 160.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Food",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Home rent",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Parent expense",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Tax",
            actualValue: 20.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Gift",
            actualValue: 40.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        // COPY
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Transport",
            actualValue: 150.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Grocery",
            actualValue: 80.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Wearing",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Electronics",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Entertainment",
            actualValue: 60.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Utility",
            actualValue: 160.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Food",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Home rent",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Parent expense",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Tax",
            actualValue: 20.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Gift",
            actualValue: 40.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Transport",
            actualValue: 150.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Grocery",
            actualValue: 80.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Wearing",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Electronics",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "BDT"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Entertainment",
            actualValue: 60.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Utility",
            actualValue: 160.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Food",
            actualValue: 120.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Home rent",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Parent expense",
            actualValue: 200.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Tax",
            actualValue: 20.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        ),
        BarChartItemUIModel(
            id: UUID().uuidString,
            name: "Gift",
            actualValue: 40.0,
            actualCurrency: "USD",
            mappedCurrency: "THB"
        )
    ]
}
