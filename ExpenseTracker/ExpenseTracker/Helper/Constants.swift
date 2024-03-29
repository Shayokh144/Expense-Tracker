//
//  Constants.swift
//  ExpenseTracker
//
//  Created by Taher on 14/11/23.
//

import Foundation

enum Constants { }

extension Constants {

    enum AppColors {
        static let redButtonColor = "#AD2533"
        static let blueButtonColor = "#2529AD"
        static let tabSelectionColor = "#3BC1AF"
        static let errorBackgroundColor = "#E72E1B"
    }
}

extension Constants {

    enum AppText {
        
        static let signInGmail = "Sign in with Gmail"
        static let signOut = "Sign out"
        static let searchLocationMap = "Search location in map"
        static let seeCurrentLocationMap = "See current location in map"
        static let tabAdd = "Add"
        static let tabProfile = "Profile"
        static let tabHistory = "History"
        static let tabAnalysis = "Analysis"
        static let addExpense = "Add expense"
        static let selectDate = "Select date"
    }
}

extension Constants {

    enum AppData {

        static var currencyList: [String] {
            ["BDT", "THB", "USD"]
        }
    }
}
