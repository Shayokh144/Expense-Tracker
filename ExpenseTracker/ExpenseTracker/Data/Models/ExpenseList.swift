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
    let expenses: [Expense]
}


struct Expense: Codable, Identifiable {

    var id: String?
    let name: String
    let price: Double
    let type: String
    let place: String
    let city: String
    let country: String
}

extension Expense {

    static var dummy: Expense {
        .init(
            name: "Bread",
            price: 22.0,
            type: "Grocery",
            place: "7-11",
            city: "Bangkok",
            country: "Thailand"
        )
    }

    static var dummy2: Expense {
        .init(
            name: "Egg",
            price: 65.0,
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
            totalCost: 87.0,
            country: "Thailand",
            expenses: [Expense.dummy, Expense.dummy2]
        )
    }
}
