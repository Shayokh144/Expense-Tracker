//
//  AddExpenseScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct AddExpenseScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @ObservedObject private var viewModel: AddExpenseViewModel

    private var saveExpenseButton: some View {
        Button {
            viewModel.saveExpenseList()
        } label: {
            Text("Save list")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    // TODO: Remove dummy
    private var getExpenseButton: some View {
        Button {
            viewModel.getExpenseList()
        } label: {
            Text("Get list")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    var body: some View {
        VStack {
            Text("Add Expense Screen")
            saveExpenseButton
            // TODO: Remove dummy
            getExpenseButton
        }
    }

    init(viewModel: AddExpenseViewModel) {
        self.viewModel = viewModel
    }
}
