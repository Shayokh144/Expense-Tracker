//
//  BarChartUIModel.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 28/5/24.
//

import Foundation

struct BarChartUIModel: Identifiable {

    let id: String
    let graphType: AnalysisGraphType
    let name: String // chart name
    let startDate: String
    let endDate: String
    var total: Double // total actualValue from chartData
    var currency: String
    let chartData: [BarChartItemUIModel]
    let barItemMaxValue: Double
}

extension BarChartUIModel {
    
    static let dummyData: BarChartUIModel = .init(
        id: UUID().uuidString,
        graphType: .categoryBar,
        name: "Data based on Category for last 10 days",
        startDate: "22 May 2024",
        endDate: "28 May 2024",
        total: 1070,
        currency: "THB",
        chartData: BarChartItemUIModel.dummyData,
        barItemMaxValue: 200.0
    )
    
    static let dummyDat2: BarChartUIModel = .init(
        id: UUID().uuidString, 
        graphType: .locationBar,
        name: "Location Data",
        startDate: "22 May 2024",
        endDate: "28 May 2024",
        total: 534,
        currency: "THB",
        chartData: BarChartItemUIModel.dummyData,
        barItemMaxValue: 200.0
    )
}
