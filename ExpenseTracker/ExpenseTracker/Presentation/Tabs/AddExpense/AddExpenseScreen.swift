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
    @StateObject private var expenseInputViewModel = ExpenseInputViewModel()

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

    private var addFromNotesButton: some View {
        Button {
            viewModel.onTapAddFromNotes()
        } label: {
            Text(Constants.AppText.addFromNotes)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.tabSelectionColor),
                textColor: .black
            )
        )
    }

    private var addManuallyButton: some View {
        Button {
            viewModel.onTapAddManually()
        } label: {
            Text(Constants.AppText.addManually)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color.green,
                textColor: .black
            )
        )
    }

    private var addMethodButtons: some View {
        VStack(spacing: 12.0) {
            addFromNotesButton
            addManuallyButton
        }
        .padding(.vertical)
    }

    private var addMoreButton: some View {
        Button {
            viewModel.onTapAddMore()
        } label: {
            Text(Constants.AppText.addMore)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color.orange,
                textColor: .black
            )
        )
        .padding(.vertical)
    }

    private var manualInputHeader: some View {
        HStack {
            Text(Constants.AppText.addNewItem)
            Spacer()
            Button(Constants.AppText.cancel) {
                viewModel.onCancelManualInput()
            }
            .buttonStyle(
                TextButtonStyle(
                    backgroundColor: Color.orange,
                    textColor: .black,
                    textPadding: EdgeInsets(top: 4.0, leading: 8.0, bottom: 4.0, trailing: 8.0)
                )
            )
        }
        .padding(.vertical)
    }

    private var currencyPickerView: some View {
        HStack {
            Text("Select currency")
            Spacer()
            CurrencyPickerView(
                currencyList: Constants.AppData.currencyList,
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
                .padding(12.0)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12.0)
                .padding(.bottom, 4.0)
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
                switch viewModel.addEntry {
                case .options:
                    addMethodButtons
                case .manual:
                    if !isKeyboardPresented {
                        manualInputHeader
                    }
                    expenseInputView
                case .compact:
                    if !isKeyboardPresented {
                        addMoreButton
                    }
                }
                if !isKeyboardPresented && !viewModel.addedLocalExpenseList.isEmpty {
                    ScrollView {
                        addedExpenseView
                    }
                    summarySection
                }
                Spacer()
            case .edit(let expense):
                editExpenseView(expense: expense)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $viewModel.isShowingNotesInput) {
            addFromNotesSheet
        }
        .alertView(
            isPresenting: $viewModel.isShowingAlert,
            title: viewModel.alertData.title,
            description: viewModel.alertData.description,
            isError: viewModel.alertData.isError,
            didTap: {
                viewModel.isShowingAlert = false
            }
        )
        .animation(.linear(duration: 0.2), value: viewModel.isShowingAlert)
        .animation(.linear(duration: 0.2), value: viewModel.addEntry)
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

    private var addFromNotesSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16.0) {
                TextEditor(text: $viewModel.notesInputText)
                    .frame(minHeight: 180.0)
                    .padding(8.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1.0)
                    )
                    .overlay(alignment: .topLeading) {
                        if viewModel.notesInputText.isEmpty {
                            Text(Constants.AppText.notesPlaceholder)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12.0)
                                .padding(.vertical, 16.0)
                                .allowsHitTesting(false)
                        }
                    }
                    .disabled(viewModel.isParsingNotes)
                Button {
                    viewModel.createListFromNotes()
                } label: {
                    HStack(spacing: 8.0) {
                        if viewModel.isParsingNotes {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(
                            viewModel.isParsingNotes
                                ? Constants.AppText.creatingList
                                : Constants.AppText.createList
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    TextButtonStyle(
                        backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                        textColor: .white
                    )
                )
                .disabled(viewModel.isParsingNotes)
                Spacer()
            }
            .padding()
            .navigationTitle(Constants.AppText.addFromNotes)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Constants.AppText.cancel) {
                        viewModel.isShowingNotesInput = false
                    }
                    .disabled(viewModel.isParsingNotes)
                }
            }
            .interactiveDismissDisabled(viewModel.isParsingNotes)
            .alertView(
                isPresenting: $viewModel.isShowingAlert,
                title: viewModel.alertData.title,
                description: viewModel.alertData.description,
                isError: viewModel.alertData.isError,
                didTap: {
                    viewModel.isShowingAlert = false
                }
            )
        }
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
