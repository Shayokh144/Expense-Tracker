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
                navigator.goBack()
            },
            label: {
                Image(systemName: "arrow.left.circle")
                    .foregroundStyle(Color(hexString: Constants.AppColors.tabSelectionColor))
            }
        )
    }
    
    var body: some View {
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
                        ExpenseDetailsItemView(expense: expense)
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
        .commonNavigationBar(
            title: "Expense Details",
            leftButton: { backButton },
            rightButton: { Color.clear }
        )
        .onAppear {
            viewModel.loadData()
        }
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
