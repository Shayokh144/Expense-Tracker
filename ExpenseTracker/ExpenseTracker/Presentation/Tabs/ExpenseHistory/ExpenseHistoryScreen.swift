//
//  ExpenseHistoryScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct ExpenseHistoryScreen: View {
    
    @ObservedObject private var viewModel: ExpenseHistoryViewModel

    private var expenseItemListView: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.expenseHistoryItems, id: \.self) { expense in
                    ExpenseHistoryItemView(uiModel: expense)
                        .padding(12.0)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12.0)
                        .padding(.bottom, 12.0)
                }
            }
        }
        .padding()
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
            Text("Total expense in BDT")
            Spacer()
            Text("\(viewModel.totalExpense.fractionTwoDigitString)")
                .font(.system(.title3))
        }
        .padding()
    }

    var body: some View {
        VStack {
            Text("Expense History")
                .font(.system(.title2))
            switch viewModel.state {
            case .loading:
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
            case .loaded, .idle:
                if !viewModel.expenseHistoryItems.isEmpty {
                    totalExpenseView
                    expenseItemListView
                }
            }
            Spacer()
        }
        .safeAreaInset(edge: .bottom, spacing: .zero) {
            loadButtonView
        }
    }

    init(viewModel: ExpenseHistoryViewModel) {
        self.viewModel = viewModel
    }
}
