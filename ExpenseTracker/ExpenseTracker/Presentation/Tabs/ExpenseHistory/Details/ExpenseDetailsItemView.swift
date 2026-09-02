//
//  ExpenseDetailsItemView.swift
//  ExpenseTracker
//
//  Created by Taher on 17/4/24.
//

import SwiftUI

struct ExpenseDetailsItemView: View {

    private let expense: Expense
    private let onEdit: () -> Void
    private let onDelete: () -> Void

    private var location: String {
        "\(expense.place), \(expense.city), \(expense.country)"
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text(expense.name)
                    .font(.system(size: 18.0, weight: .bold))
                Spacer()
                Text(expense.price.fractionTwoDigitString)
                    .font(.system(size: 18.0, weight: .bold))
            }
            Text(expense.type)
                .font(.system(size: 14.0, weight: .regular))
            Text(location)
                .font(.system(size: 14.0, weight: .regular))
            HStack {
                Spacer()
                Button(action: onEdit) {
                    Text(Constants.AppText.edit)
                        .frame(width: 70.0)
                }
                .buttonStyle(
                    TextButtonStyle(
                        backgroundColor: Color.green,
                        textColor: .black,
                        textPadding: EdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
                    )
                )
                Button(action: onDelete) {
                    Text(Constants.AppText.delete)
                        .frame(width: 70.0)
                }
                .buttonStyle(
                    TextButtonStyle(
                        backgroundColor: Color(hexString: Constants.AppColors.redButtonColor),
                        textColor: .white,
                        textPadding: EdgeInsets(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
                    )
                )
            }
            .padding(.top, 4.0)
        }
    }

    var body: some View {
        contentView
    }

    init(
        expense: Expense,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.expense = expense
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
}
