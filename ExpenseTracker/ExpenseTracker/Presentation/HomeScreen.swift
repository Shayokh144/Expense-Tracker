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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
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
