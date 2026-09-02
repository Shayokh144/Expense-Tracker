//
//  ExpenseHistoryScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct ExpenseHistoryScreen: View {

    @StateObject private var viewModel: ExpenseHistoryViewModel
    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @State private var expenseIdPendingDelete: String?

    private var currencyPickerView: some View {
        CurrencyPickerView(
            currencyList: Constants.AppData.currencyList,
            selectedCurrency: $viewModel.selectedCurrency
        )
        .padding(.horizontal)
    }

    private var startDateView: some View {
        DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .clipped()
            .labelsHidden()

    }

    private var endDateView: some View {
        DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .clipped()
            .labelsHidden()
    }

    private var filterView: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text("Start date")
                    .font(.system(size: 16.0, weight: .semibold))
                Spacer()
                Text("End date")
                    .font(.system(size: 16.0, weight: .semibold))
            }
            HStack {
                startDateView
                Spacer()
                Toggle("", isOn: $viewModel.isFilterOn)
                    .labelsHidden()
                Spacer()
                endDateView
            }
        }
        .padding()
    }

    private var expenseItemListView: some View {
        List {
            ForEach(viewModel.uiExpenseList, id: \.self) { expense in
                Button(
                    action: {
                        openExpenseDetails(for: expense)
                    },
                    label: {
                        ExpenseHistoryItemView(uiModel: expense)
                            .padding(12.0)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12.0)
                    }
                )
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        expenseIdPendingDelete = expense.id
                    } label: {
                        Label(Constants.AppText.delete, systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .padding(.top, 4.0)
    }

    private var loadButtonView: some View {
        VStack {
            Rectangle()
                .fill(Color(hexString: Constants.AppColors.blueButtonColor))
                .frame(height: 1.0)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -16.0)
                .padding(.bottom, 8.0)
            Button(
                action: {
                    viewModel.loadExpenseData()
                },
                label: {
                    Text("Load expense data")
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(
                TextButtonStyle(
                    backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                    textColor: .white
                )
            )
            .disabled(viewModel.state == .loading)
        }
        .padding(.bottom)
        .padding(.horizontal)
    }

    private var totalExpenseView: some View {
        HStack {
            Text("Total expense in \(viewModel.selectedCurrency)")
                .font(.system(size: 14.0, weight: .bold))
            Spacer()
            Text("\(viewModel.totalExpense.fractionTwoDigitString)")
                .font(.system(size: 20.0, weight: .bold))
        }
        .padding([.horizontal, .top])
    }

    var body: some View {
        VStack(spacing: .zero) {
            Text("Expense History")
                .font(.system(.title2))
            switch viewModel.state {
            case .loading:
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
            case .loaded, .idle:
                filterView
                currencyPickerView
                if !viewModel.uiExpenseList.isEmpty {
                    totalExpenseView
                    expenseItemListView
                }
            }
            Spacer()
        }
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            loadButtonView
        }
        .confirmationDialog(
            Constants.AppText.deleteExpenseListTitle,
            isPresented: Binding(
                get: { expenseIdPendingDelete != nil },
                set: { isPresented in
                    if !isPresented {
                        expenseIdPendingDelete = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button(Constants.AppText.delete, role: .destructive) {
                if let expenseIdPendingDelete {
                    viewModel.deleteExpenseList(id: expenseIdPendingDelete)
                }
                expenseIdPendingDelete = nil
            }
            Button(Constants.AppText.cancel, role: .cancel) {
                expenseIdPendingDelete = nil
            }
        } message: {
            Text(Constants.AppText.deleteExpenseListMessage)
        }
    }

    init(viewModel: ExpenseHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private func openExpenseDetails(for expense: ExpenseHistoryItemUIModel) {
        let historyViewModel = viewModel
        let detailsViewModel = ExpenseHistoryDetailsViewModel(
            id: expense.id,
            onExpenseListDeleted: { id in
                historyViewModel.removeExpenseList(id: id)
            },
            onExpenseListUpdated: { updatedList in
                historyViewModel.updateExpenseList(updatedList)
            }
        )
        navigator.goToExpenseHistoryDetailsView(viewModel: detailsViewModel)
    }
}
