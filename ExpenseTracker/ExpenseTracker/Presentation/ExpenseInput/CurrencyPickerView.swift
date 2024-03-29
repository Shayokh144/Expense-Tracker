//
//  CurrencyPickerView.swift
//  ExpenseTracker
//
//  Created by Taher on 15/1/24.
//

import SwiftUI

struct CurrencyPickerView: View {

    private let currencyList: [String]
    @Binding private var selectedCurrency: String

    var body: some View {
        HStack(spacing: .zero) {
            Spacer()
            Picker("", selection: $selectedCurrency) {
                ForEach(currencyList, id: \.self) {
                    Text($0)
//                        .foregroundColor(.black)
                }
            }
            .pickerStyle(.menu)
            .clipped()
            .labelsHidden()
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(
                        Color(hexString: Constants.AppColors.tabSelectionColor),
                        lineWidth: 1.0
                    )
            )
//            .background(.white)
        }

    }

    init(currencyList: [String], selectedCurrency: Binding<String>) {
        self.currencyList = currencyList
        _selectedCurrency = selectedCurrency
    }
}
