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
    let graphType: AnalysisGraphType
    let itemName: String
    let totalPrice: String
    
    init(
        barChartUIModel: BarChartUIModel,
        graphType: AnalysisGraphType,
        itemName: String,
        totalPrice: String
    ) {
        self.barChartUIModel = barChartUIModel
        self.graphType = graphType
        self.itemName = itemName
        self.totalPrice = totalPrice
    }
}
