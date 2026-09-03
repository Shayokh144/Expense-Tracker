//
//  MonthlyBudget.swift
//  ExpenseTracker
//
//  Created by Taher on 6/7/26.
//

import Foundation
import SwiftData

@Model
final class MonthlyBudget {

    var amount: Double
    var currency: String
    var month: Int
    var year: Int
    var budgetDate: Date

    init(
        amount: Double,
        currency: String,
        month: Int,
        year: Int,
        budgetDate: Date
    ) {
        self.amount = amount
        self.currency = currency
        self.month = month
        self.year = year
        self.budgetDate = budgetDate
    }
}
