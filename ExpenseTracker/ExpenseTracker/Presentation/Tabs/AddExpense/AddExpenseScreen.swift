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
    @State private var isKeyboardPresented: Bool = false
    private let expenseInputViewModel = ExpenseInputViewModel()
    private var saveExpenseButton: some View {
        Button {
            viewModel.saveExpenseList()
        } label: {
            Text("Save list")
                .frame(width: (UIScreen.main.bounds.width) / 2.0 - 48.0)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
        .padding(.top, 16.0)
        .padding(.bottom, 32.0)
    }

    private var currencyPickerView: some View {
        HStack {
            Text("Select currency")
            Spacer()
            CurrencyPickerView(
                currencyList: viewModel.currencyList,
                selectedCurrency: $viewModel.selectedCurrency
            )
        }
    }

    private var datePickerView: some View {
        DatePicker(
            selection: $viewModel.selectedDate,
            in: ...Date.now,
            displayedComponents: .date
        ) {
            Text(Constants.AppText.selectDate)
        }
    }

    private var screenTitleView: some View {
        Text(Constants.AppText.addExpense)
            .font(.system(.title2))
    }

    private var expenseInputView: some View {
        ExpenseInputView(
            viewModel: expenseInputViewModel
        ) { expense in
            viewModel.onAddLocalExpense(expense: expense)
        }
    }

    private var addedExpenseView: some View {
        VStack {
            ForEach(viewModel.addedLocalExpenseList, id: \.self) { expense in
                VStack(alignment: .leading, spacing: 4.0) {
                    HStack {
                        Text(expense.name)
                            .font(.system(size: 16.0))
                        Spacer()
                        Text(expense.price.fractionTwoDigitString)
                            .font(.system(size: 16.0))
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text("\(expense.place)")
                                .font(.system(size: 12.0))
                            Text("\(expense.city), \(expense.country)")
                                .font(.system(size: 10.0))
                        }
                        Spacer()
                        Button(
                            action: {
                                viewModel.onTapEditButton(expense: expense)
                            },
                            label: {
                                Text("Edit")
                                    .frame(width: 70.0)
                            }
                        )
                        .buttonStyle(
                            TextButtonStyle(
                                backgroundColor: Color.green,
                                textColor: .black,
                                textPadding: EdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
                            )
                        )
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 1)
                )
                .padding(.bottom, 8.0)
            }
        }
    }

    private var summarySection: some View {
        HStack(spacing: 4.0) {
            Text("Total:")
            Text(viewModel.currentTotal.fractionTwoDigitString)
                .font(.system(.title2))
            Spacer()
            saveExpenseButton
        }
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .add:
                if !isKeyboardPresented {
                    screenTitleView
                    datePickerView
                    currencyPickerView
                }
                Text("Add new item")
                    .padding(.vertical)
                expenseInputView
                if !isKeyboardPresented && !viewModel.addedLocalExpenseList.isEmpty {
                    ScrollView {
                        addedExpenseView
                    }
                }
                if !isKeyboardPresented && !viewModel.addedLocalExpenseList.isEmpty {
                    summarySection
                }
                Spacer()
            case .edit(let expense):
                editExpenseView(expense: expense)
            }
        }
        .padding(.horizontal)
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillShowNotification)
        ) { _ in
            withAnimation {
                isKeyboardPresented = true
            }
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillHideNotification)
        ) { _ in
            withAnimation {
                isKeyboardPresented = false
            }
        }
    }

    init(viewModel: AddExpenseViewModel) {
        self.viewModel = viewModel
    }

    private func editExpenseView(expense: Expense) -> some View {
        ExpenseEditView(
            editName: $viewModel.editName,
            editPrice: $viewModel.editPrice,
            editType: $viewModel.editType,
            editPlace: $viewModel.editPlace,
            editCountry: $viewModel.editCountry,
            editCity: $viewModel.editCity,
            onTapSaveEdit: {
                viewModel.onSaveEditExpense(expense: expense)
            }
        )
    }
}
