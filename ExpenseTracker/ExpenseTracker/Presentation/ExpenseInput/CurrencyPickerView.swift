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
        HStack {
            Spacer()
            Picker("", selection: $selectedCurrency) {
                ForEach(currencyList, id: \.self) {
                    Text($0)
//                        .foregroundColor(.black)
                }
            }
            .pickerStyle(.menu)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(
                        Color.purple,
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
