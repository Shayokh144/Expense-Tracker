//
//  BudgetExpenseSheetView.swift
//  ExpenseTracker
//
//  Created by Taher on 8/7/26.
//

import SwiftUI

struct BudgetExpenseSheetView: View {

    @ObservedObject private var viewModel: ProfileScreenViewModel

    private var currency: String {
        viewModel.budgetProgressUIModel?.currency ?? ""
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.budgetExpenseItems.isEmpty {
                    Text(Constants.AppText.budgetExpenseEmpty)
                        .font(.system(size: 14.0))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.budgetExpenseItems) { item in
                            budgetExpenseRow(item: item)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Constants.AppText.budgetExpenseDetails)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Constants.AppText.done) {
                        viewModel.onDismissBudgetExpenseSheet()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func budgetExpenseRow(item: BudgetExpenseItemUIModel) -> some View {
        Button {
            viewModel.onToggleBudgetExpenseItem(id: item.id)
        } label: {
            HStack(spacing: 12.0) {
                Image(
                    systemName: item.isSelected ?
                    "checkmark.square.fill" :
                    "square"
                )
                .foregroundColor(
                    Color(hexString: Constants.AppColors.tabSelectionColor)
                )
                Text(item.name)
                    .font(.system(size: 16.0))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(item.cost.fractionTwoDigitString) \(currency)")
                    .font(.system(size: 14.0, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 4.0)
        }
        .buttonStyle(.plain)
    }

    init(viewModel: ProfileScreenViewModel) {
        self.viewModel = viewModel
    }
}
