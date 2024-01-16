//
//  ExpenseEditView.swift
//  ExpenseTracker
//
//  Created by Taher on 11/1/24.
//

import SwiftUI

struct ExpenseEditView: View {
    
    @Binding var editName: String
    @Binding var editPrice: String
    @Binding var editType: String
    @Binding var editCountry: String
    @Binding var editCity: String
    private let onTapSaveEdit: () -> Void
    
    private var nameEditView: some View {
        return VStack(alignment: .leading, spacing: 4.0) {
            Text("Name")
            TextField("", text: $editName)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var priceEditView: some View {
        return VStack(alignment: .leading, spacing: 4.0) {
            Text("Price")
            TextField("", text: $editPrice)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var typeEditView: some View {
        return VStack(alignment: .leading, spacing: 4.0) {
            Text("Type")
            TextField("", text: $editType)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var countryEditView: some View {
        return VStack(alignment: .leading, spacing: 4.0) {
            Text("Country")
            TextField("", text: $editCountry)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var cityEditView: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text("City")
            TextField("", text: $editCity)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var body: some View {
        VStack {
            Text("Edit Expense")
                .font(.system(.title2))
                .padding(.bottom, 8.0)
                .padding(.bottom, 16.0)
            ScrollView {
                VStack(spacing: 12.0) {
                    nameEditView
                    priceEditView
                    typeEditView
                    cityEditView
                    countryEditView
                    Button {
                        onTapSaveEdit()
                    } label: {
                        Text("Save changes")
                            .font(.system(size: 16.0, weight: .bold))
                            .foregroundColor(.white)
                            .frame(height: 40.0)
                            .frame(maxWidth: .infinity)
                            .background(.green)
                            .cornerRadius(8.0)
                    }
                    .padding(.top, 16.0)
                    Spacer()
                }
            }
        }
    }

    init(
        editName: Binding<String>,
        editPrice: Binding<String>,
        editType: Binding<String>,
        editCountry: Binding<String>,
        editCity: Binding<String>,
        onTapSaveEdit: @escaping () -> Void
    ) {
        _editName = editName
        _editPrice = editPrice
        _editType = editType
        _editCountry = editCountry
        _editCity = editCity
        self.onTapSaveEdit = onTapSaveEdit
    }
}
