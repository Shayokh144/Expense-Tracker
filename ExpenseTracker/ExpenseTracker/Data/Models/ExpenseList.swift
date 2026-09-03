//
//  ExpenseList.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Foundation

struct ExpenseList: Codable, Identifiable {

    var id: String?
    let dateTime: String
    let totalCost: Double
    let country: String
    let currency: String?
    let expenses: [Expense]
    var dayDifferenceFromToday: Int?
    
    func withDateDifference(difference: Int?) -> ExpenseList {
        ExpenseList(
            id: id,
            dateTime: dateTime,
            totalCost: totalCost,
            country: country,
            currency: currency,
            expenses: expenses,
            dayDifferenceFromToday: difference
        )
    }

    func updating(expenses updatedExpenses: [Expense]) -> ExpenseList {
        let total = updatedExpenses.map(\.price).reduce(0.0, +)
        let updatedCountry = updatedExpenses.first?.country ?? country
        return ExpenseList(
            id: id,
            dateTime: dateTime,
            totalCost: total,
            country: updatedCountry,
            currency: currency,
            expenses: updatedExpenses,
            dayDifferenceFromToday: dayDifferenceFromToday
        )
    }
}


struct Expense: Codable, Identifiable, Hashable {

    var id: String?
    var name: String
    var price: Double
    var type: String
    var place: String
    var city: String
    var country: String
}

extension Expense {

    static var dummy: Expense {
        .init(
            name: "Oil",
            price: 40.0,
            type: "Grocery",
            place: "7-11",
            city: "Bangkok",
            country: "Thailand"
        )
    }

    static var dummy2: Expense {
        .init(
            name: "Egg",
            price: 70.0,
            type: "Grocery",
            place: "7-11",
            city: "Bangkok",
            country: "Thailand"
        )
    }
}

extension ExpenseList {

    static var dummy: ExpenseList {
        .init(
            dateTime: Date.currentDateString,
            totalCost: 110.0,
            country: "Thailand",
            currency: "THB",
            expenses: [Expense.dummy, Expense.dummy2]
        )
    }
}
