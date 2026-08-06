//
//  MonthlyBudgetUseCase.swift
//  ExpenseTracker
//
//  Created by Taher on 6/7/26.
//

import Foundation
import SwiftData

@MainActor
final class MonthlyBudgetUseCase {

    static let shared = MonthlyBudgetUseCase()

    let modelContainer: ModelContainer

    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    private init() {
        modelContainer = try! ModelContainer(for: MonthlyBudget.self)
    }

    func hasBudgetForCurrentMonth() -> Bool {
        let components = Calendar.current.dateComponents([.month, .year], from: .now)
        guard let month = components.month, let year = components.year else {
            return false
        }
        return fetchBudget(month: month, year: year) != nil
    }

    func fetchBudget(month: Int, year: Int) -> MonthlyBudget? {
        let predicate = #Predicate<MonthlyBudget> { budget in
            budget.month == month && budget.year == year
        }
        let descriptor = FetchDescriptor<MonthlyBudget>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    func saveBudget(amount: Double, currency: String, date: Date) throws {
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        guard let month = components.month, let year = components.year else {
            throw CommonError.invalidData
        }

        if let existingBudget = fetchBudget(month: month, year: year) {
            existingBudget.amount = amount
            existingBudget.currency = currency
            existingBudget.budgetDate = date
        } else {
            let budget = MonthlyBudget(
                amount: amount,
                currency: currency,
                month: month,
                year: year,
                budgetDate: date
            )
            modelContext.insert(budget)
        }

        try modelContext.save()
    }
}
