//
//  ExpenseDetailsItemView.swift
//  ExpenseTracker
//
//  Created by Taher on 17/4/24.
//

import SwiftUI

struct ExpenseDetailsItemView: View {
    
    private let expense: Expense
    
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
        }
    }
    
    var body: some View {
        contentView
    }
    
    init(expense: Expense) {
        self.expense = expense
    }
}
