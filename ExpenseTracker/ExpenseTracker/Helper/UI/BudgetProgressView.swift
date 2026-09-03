//
//  BudgetProgressView.swift
//  ExpenseTracker
//
//  Created by Taher on 7/7/26.
//

import SwiftUI

struct BudgetProgressView: View {

    @ObservedObject private var viewModel: ProfileScreenViewModel
    private let onTapFilterExpenses: () -> Void
    private let onTapUpdateBudget: () -> Void

    var body: some View {
        if let uiModel = viewModel.budgetProgressUIModel {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("\(Constants.AppText.remainingThisMonth): \(remainingText(uiModel: uiModel))")
                    .font(.system(size: 16.0, weight: .semibold))

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6.0)
                            .fill(Color(hexString: Constants.AppColors.budgetRemainingColor))

                        RoundedRectangle(cornerRadius: 6.0)
                            .fill(Color(hexString: Constants.AppColors.budgetSpentColor))
                            .frame(width: geometry.size.width * uiModel.spentFraction)
                    }
                }
                .frame(height: 12.0)

                Text(usageText(uiModel: uiModel))
                    .font(.system(size: 12.0))
                    .foregroundColor(.gray)

                VStack(spacing: 8.0) {
                    actionButton(
                        title: Constants.AppText.filterExpenses,
                        action: onTapFilterExpenses
                    )

                    if !viewModel.isUpdateBudgetVisible {
                        actionButton(
                            title: Constants.AppText.updateBudget,
                            action: onTapUpdateBudget
                        )
                    }
                }
                .padding(.top, 4.0)
            }
            .padding(12.0)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12.0)
        }
    }

    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14.0, weight: .semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white,
                textPadding: EdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
            )
        )
    }

    private func remainingText(uiModel: BudgetProgressUIModel) -> String {
        "\(uiModel.remainingAmount.fractionTwoDigitString) \(uiModel.currency)"
    }

    private func usageText(uiModel: BudgetProgressUIModel) -> String {
        String(
            format: Constants.AppText.budgetUsedFormat,
            uiModel.spentAmount.fractionTwoDigitString,
            uiModel.budgetAmount.fractionTwoDigitString,
            uiModel.currency
        )
    }

    init(
        viewModel: ProfileScreenViewModel,
        onTapFilterExpenses: @escaping () -> Void,
        onTapUpdateBudget: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTapFilterExpenses = onTapFilterExpenses
        self.onTapUpdateBudget = onTapUpdateBudget
    }
}
