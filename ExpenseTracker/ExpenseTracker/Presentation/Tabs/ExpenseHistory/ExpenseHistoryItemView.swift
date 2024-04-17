//
//  ExpenseHistoryItemView.swift
//  ExpenseTracker
//
//  Created by nimble on 16/1/24.
//

import SwiftUI

struct ExpenseHistoryItemView: View {

    private let uiModel: ExpenseHistoryItemUIModel

    private var itemCountText: String {
        if uiModel.itemCount <= 1 {
            return "\(uiModel.itemCount) Item"
        }
        return "\(uiModel.itemCount) Items"
    }

    private var titleText: String {
        if uiModel.itemCount <= 1 {
            return uiModel.mostExpensiveItemName
        }
        return "\(uiModel.mostExpensiveItemName) and others"
    }

    private var leftColumnView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(titleText)
                .font(.system(size: 16.0, weight: .bold))
                .padding(.bottom, 4.0)
            HStack(spacing: 8.0) {
                Text(itemCountText)
                    .font(.system(size: 14.0, weight: .semibold))
                Text("·")
                    .font(.system(size: 14.0, weight: .semibold))
                Text(uiModel.country)
                    .font(.system(size: 14.0, weight: .semibold))
            }

            Text(uiModel.dateTimeString)
                .font(.system(size: 16.0, weight: .semibold))
                .padding(.top, 4.0)
        }
    }

    private var rightColumnView: some View {
        HStack(alignment: .bottom, spacing: 4.0) {
            Text(uiModel.currency.currencySymbol)
                .font(.system(size: 14.0, weight: .semibold))
            Text(uiModel.totalCost)
                .font(.system(size: 16.0, weight: .bold))
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            leftColumnView
            Spacer()
            rightColumnView
        }
    }

    init(uiModel: ExpenseHistoryItemUIModel) {
        self.uiModel = uiModel
    }
}
