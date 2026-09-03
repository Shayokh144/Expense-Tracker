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
        static let budgetSpentColor = "#E67E22"
        static let budgetRemainingColor = "#3BC1AF"
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
        static let monthlyBudget = "Monthly budget"
        static let budgetAmount = "Budget amount"
        static let selectCurrency = "Select currency"
        static let saveBudget = "Save budget"
        static let updateBudget = "Update budget"
        static let budgetAlertTitle = "Set monthly budget"
        static let budgetAlertMessage = "You have not set a budget for this month. Set one to track your spending."
        static let setBudget = "Set budget"
        static let cancel = "Cancel"
        static let budgetSaveSuccess = "Monthly budget saved successfully."
        static let budgetSaveFailed = "Failed to save monthly budget."
        static let budgetInvalidAmount = "Please enter a valid budget amount."
        static let remainingThisMonth = "Remaining this month"
        static let budgetUsedFormat = "%@ of %@ %@ used"
        static let done = "Done"
        static let filterExpenses = "Filter expenses"
        static let budgetExpenseDetails = "Monthly expenses"
        static let budgetExpenseEmpty = "No expenses found for this month."
        static let edit = "Edit"
        static let delete = "Delete"
        static let deleteExpenseListTitle = "Delete expense list"
        static let deleteExpenseListMessage = "This will permanently delete this expense list."
        static let deleteExpenseItemTitle = "Delete expense"
        static let deleteExpenseItemMessage = "This will permanently delete this expense item."
        static let expenseUpdateSuccess = "Expense updated successfully."
        static let expenseUpdateFailed = "Failed to update expense."
        static let expenseDeleteSuccess = "Expense deleted successfully."
        static let expenseDeleteFailed = "Failed to delete expense."
        static let addFromNotes = "Add from notes"
        static let addManually = "Add manually"
        static let addMore = "Add more"
        static let addNewItem = "Add new item"
        static let createList = "Create list"
        static let creatingList = "Creating list..."
        static let notesPlaceholder = """
        electric bill 500 Aspire
        home rent 10000 Aspire
        egg, milk 200 7-11
        """
        static let notesEmpty = "Please write some expenses first."
        static let notesParseFailed = "Could not create a list from these notes. Try again."
        static let notesServiceBusy = "The notes service is busy. Please try again."
        static let notesNoItems = "No expenses were found in these notes."
        static let expenseListAddSuccess = "Expense list added successfully."
        static let expenseListAddFailed = "Failed to add expense list"
    }
}

extension Constants {

    enum Gemini {

        static let modelName = "gemini-3.6-flash"
        static let maxContextItems = 40
        static let maxRetries = 2
    }
}

extension Constants {

    enum AppData {

        static var currencyList: [String] {
            ["THB", "BDT", "USD"]
        }
        
        static let oneThbInBdt: Double = 3.8
        
        static func currencyConversionRate(
            fromCurrency:  String,
            toCurrency: String
        ) -> Double {
            if fromCurrency == "THB" {
                if toCurrency == "USD" {
                    return 0.27
                } else if toCurrency == "BDT" {
                    return oneThbInBdt
                }
            }
            if fromCurrency == "BDT" {
                if toCurrency == "USD" {
                    return 0.0085
                } else if toCurrency == "THB" {
                    return 1 / oneThbInBdt
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
