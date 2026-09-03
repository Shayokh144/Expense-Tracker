//
//  BudgetProgressUIModel.swift
//  ExpenseTracker
//
//  Created by Taher on 7/7/26.
//

import Foundation

struct BudgetProgressUIModel: Equatable {

    let remainingAmount: Double
    let spentAmount: Double
    let budgetAmount: Double
    let currency: String

    var spentFraction: Double {
        guard budgetAmount > 0 else { return 0 }
        return min(spentAmount / budgetAmount, 1.0)
    }
}
