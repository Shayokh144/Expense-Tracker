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
            ["THB", "BDT", "USD"]
        }
        
        static func currencyConversionRate(
            fromCurrency:  String,
            toCurrency: String
        ) -> Double {
            if fromCurrency == "THB" {
                if toCurrency == "USD" {
                    return 0.27
                } else if toCurrency == "BDT" {
                    return 3.2
                }
            }
            if fromCurrency == "BDT" {
                if toCurrency == "USD" {
                    return 0.0085
                } else if toCurrency == "THB" {
                    return 1 / 3.2
                }
            }
            if fromCurrency == "USD" {
                if toCurrency == "BDT" {
                    return 117.9
                } else if toCurrency == "THB" {
                    return 36.94
                }
            }
            return 1.0
        }
    }
}
