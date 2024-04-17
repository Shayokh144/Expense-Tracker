//
//  ExpenseHistoryItemUIModel.swift
//  ExpenseTracker
//
//  Created by Taher on 16/1/24.
//

import Foundation

struct ExpenseHistoryItemUIModel: Hashable, Identifiable {

    let id: String
    let mostExpensiveItemName: String
    let itemCount: Int
    let totalCost: String
    let dateTimeString: String
    let currency: String
    let country: String
    let dateTime: Date
}
