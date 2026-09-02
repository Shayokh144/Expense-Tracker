//
//  ExpenseHistoryDetailsScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 7/2/24.
//

import SwiftUI

struct ExpenseHistoryDetailsScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @StateObject private var viewModel: ExpenseHistoryDetailsViewModel
    private let onTapBack: () -> Void

    private var backButton: some View {
        Button(
            action: {
                switch viewModel.state {
                case .editing:
                    viewModel.onCancelEdit()
                case .viewing:
                    navigator.goBack()
                }
            },
            label: {
                Image(systemName: "arrow.left.circle")
                    .foregroundStyle(Color(hexString: Constants.AppColors.tabSelectionColor))
            }
        )
    }

    private var deleteListButton: some View {
        Button(
            action: {
                viewModel.onTapDeleteList()
            },
            label: {
                Image(systemName: "trash")
                    .foregroundStyle(Color(hexString: Constants.AppColors.redButtonColor))
            }
        )
        .disabled(viewModel.isSaving)
    }

    private var detailsContentView: some View {
        VStack(alignment: .leading) {
            if let expenseList = viewModel.expenseList {
                HStack {
                    Text("Total:")
                    Spacer()
                    HStack {
                        Text(expenseList.totalCost.fractionTwoDigitString)
                            .font(.system(size: 26.0, weight: .bold))
                        Text(expenseList.currency ?? "No currency found")
                    }
                }
                .padding(.top)

                HStack {
                    Text(getDisplayTime(dateTime: expenseList.dateTime))
                        .font(.system(size: 12.0, weight: .regular))
                    Spacer()
                    Text(expenseList.country)
                        .font(.system(size: 16.0, weight: .regular))
                }
                .padding(.bottom, 8.0)

                ScrollView {
                    ForEach(expenseList.expenses, id: \.self) { expense in
                        ExpenseDetailsItemView(
                            expense: expense,
                            onEdit: {
                                viewModel.onTapEditButton(expense: expense)
                            },
                            onDelete: {
                                viewModel.onTapDeleteItem(expense: expense)
                            }
                        )
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12.0)
                        .padding(.bottom, 8.0)
                    }
                }
                .padding(.top)
            }
        }
        .padding(.horizontal)
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
        .padding(.horizontal)
        .disabled(viewModel.isSaving)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .viewing:
                detailsContentView
            case .editing(let expense):
                editExpenseView(expense: expense)
            }
        }
        .commonNavigationBar(
            title: viewModel.state == .viewing ? "Expense Details" : "Edit Expense",
            showsRightButton: viewModel.state == .viewing,
            leftButton: { backButton },
            rightButton: { deleteListButton }
        )
        .overlay {
            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: viewModel.didDeleteList) { didDelete in
            if didDelete {
                navigator.goBack()
            }
        }
        .confirmationDialog(
            Constants.AppText.deleteExpenseListTitle,
            isPresented: $viewModel.isShowingDeleteListConfirmation,
            titleVisibility: .visible
        ) {
            Button(Constants.AppText.delete, role: .destructive) {
                viewModel.confirmDeleteList()
            }
            Button(Constants.AppText.cancel, role: .cancel) { }
        } message: {
            Text(Constants.AppText.deleteExpenseListMessage)
        }
        .confirmationDialog(
            Constants.AppText.deleteExpenseItemTitle,
            isPresented: $viewModel.isShowingDeleteItemConfirmation,
            titleVisibility: .visible
        ) {
            Button(Constants.AppText.delete, role: .destructive) {
                viewModel.confirmDeleteItem()
            }
            Button(Constants.AppText.cancel, role: .cancel) { }
        } message: {
            Text(Constants.AppText.deleteExpenseItemMessage)
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
    }

    init(
        viewModel: ExpenseHistoryDetailsViewModel,
        onTapBack: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onTapBack = onTapBack
    }

    private func getDisplayTime(dateTime: String) -> String {
        guard let date = DateFormatter.fullDateTimeFormat.date(from: dateTime) else {
            return ""
        }
        let dateTimeString = DateFormatter.displayDateTimeFormat.string(from: date)
        return dateTimeString
    }
}
