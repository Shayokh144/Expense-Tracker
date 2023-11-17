//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 13/11/23.
//

import SwiftUI

struct HomeScreen: View {

    @ObservedObject private var viewModel: HomeViewModel

    var body: some View {
        VStack {
            Text(viewModel.addressString)
            Button {

            } label: {
                Text("Show map view")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            viewModel.viewDidAppear()
        }
    }

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
}
