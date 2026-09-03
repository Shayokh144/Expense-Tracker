//
//  BudgetExpenseItemUIModel.swift
//  ExpenseTracker
//
//  Created by Taher on 8/7/26.
//

import Foundation

struct BudgetExpenseItemUIModel: Identifiable, Equatable {

    let id: String
    let name: String
    let cost: Double
    var isSelected: Bool
}
