//
//  ExpenseInputView.swift
//  ExpenseTracker
//
//  Created by Taher on 10/1/24.
//

import SwiftUI

struct ExpenseInputView: View {

    @ObservedObject private var viewModel: ExpenseInputViewModel
    private var onTapAddExpense: (Expense) -> Void

    private var placeSearchResult: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.searchResults, id: \.self) { result in
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(result.name)
                            .font(.system(size: 16.0))
                        Text("\(result.city), \(result.country)")
                            .font(.system(size: 12.0))
                        Rectangle()
                            .fill(Color.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 1.0)
                    }
                    .padding(.bottom, 8.0)
                    .background(Color.clear)
                    .onTapGesture {
                        viewModel.onTapPlaceSearchResult(result: result)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private var addExpenseButton: some View {
        Button(
            action: {
                let expense = viewModel.onTapAddExpense()
                onTapAddExpense(expense)
            },
            label: {
                Text("Add to list")
                    .frame(maxWidth: .infinity)
            }
        )
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color.green,
                textColor: .black
            )
        )
        .padding(.vertical)
    }

    var body: some View {
        VStack(spacing: 16.0) {
            TextField("product name", text: $viewModel.productName)
                .textFieldStyle(.roundedBorder)
            HStack(spacing: 16.0) {
                TextField("product price", text: $viewModel.productPrice)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                TextField("product type", text: $viewModel.productType)
                    .textFieldStyle(.roundedBorder)
            }
            if let selectedPlace = viewModel.selectedPlace {
                selectedLocationView(address: selectedPlace)
                addExpenseButton
            } else {
                TextField("place", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                placeSearchResult
            }
        }
    }

    init(
        viewModel: ExpenseInputViewModel,
        onTapAddExpense: @escaping (Expense) -> Void
    ) {
        self.viewModel = viewModel
        self.onTapAddExpense = onTapAddExpense
    }

    private func selectedLocationView(address: PlaceAddress) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(address.name)
                    .font(.system(size: 16.0))
                Text("\(address.city), \(address.country)")
                    .font(.system(size: 12.0))
            }
            Spacer()
            Button(
                action: {
                    viewModel.onTapChangeLocation()
                },
                label: {
                    Text("Change")
                        .frame(width: 100.0)
                }
            )
            .buttonStyle(
                TextButtonStyle(
                    backgroundColor: Color.orange,
                    textColor: .black
                )
            )
        }
    }
}
