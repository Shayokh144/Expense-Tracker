//
//  ExpenseAnalysisDetailsViewModel.swift
//  ExpenseTracker
//
//  Created by Taher's nimble macbook on 26/6/24.
//

import Combine
import Foundation

final class ExpenseAnalysisDetailsViewModel: ObservableObject {
    
    @Published var barChartUIModel: BarChartUIModel
    @Published var isCategoryFilterOn = true {
        didSet {
            updateUIData()
        }
    }
    let graphType: AnalysisGraphType
    let itemName: String
    let totalPrice: String
    let categoryDict: [String: String]
    let initialBarChartUIModel: BarChartUIModel
    var categoryBarChartUIModel: BarChartUIModel?

    init(
        barChartUIModel: BarChartUIModel,
        graphType: AnalysisGraphType,
        itemName: String,
        totalPrice: String,
        categoryDict: [String: String]
    ) {
        self.barChartUIModel = barChartUIModel
        self.graphType = graphType
        self.itemName = itemName
        self.totalPrice = totalPrice
        self.categoryDict = categoryDict
        self.initialBarChartUIModel = barChartUIModel
    }
    
    func updateUIData() {
        if graphType == .categoryBar {
            return
        }
        guard isCategoryFilterOn else {
            barChartUIModel = initialBarChartUIModel
            return
        }
        barChartUIModel = calculateCategoryBarChartUIModel()
    }
    
    private func calculateCategoryBarChartUIModel() -> BarChartUIModel {
        guard let categoryBarChartUIModel = categoryBarChartUIModel else {
            var newBarUIData: [BarChartItemUIModel] = []
            var chartCategoryDict: [String: Double] = [:]
            var maxCost: Double = 0.0
            var totalCost: Double = 0.0
            for chartItem in initialBarChartUIModel.chartData {
                if let categoryName = categoryDict[chartItem.id] {
                    chartCategoryDict[categoryName] = (chartCategoryDict[categoryName] ?? 0) + chartItem.actualValue
                }
            }
            for (key, value) in chartCategoryDict {
                newBarUIData.append(
                    BarChartItemUIModel(
                        id: key,
                        name: key,
                        actualValue: value,
                        actualCurrency: "THB",
                        mappedCurrency: "THB"
                    )
                )
                maxCost = max(maxCost, value)
                totalCost += value
            }
            newBarUIData = newBarUIData.sorted { $0.actualValue > $1.actualValue }
            let detailsUIModel = BarChartUIModel(
                id: barChartUIModel.id,
                graphType: barChartUIModel.graphType,
                name: barChartUIModel.name,
                startDate: barChartUIModel.startDate,
                endDate: barChartUIModel.endDate,
                total: totalCost,
                currency: "THB",
                chartData: newBarUIData,
                barItemMaxValue: maxCost
            )
            categoryBarChartUIModel = detailsUIModel
            return detailsUIModel
        }
        return categoryBarChartUIModel
    }
}
