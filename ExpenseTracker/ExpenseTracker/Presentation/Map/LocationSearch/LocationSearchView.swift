//
//  LocationSearchView.swift
//  ExpenseTracker
//
//  Created by Taher on 22/11/23.
//

import SwiftUI

struct LocationSearchView: View {

    @ObservedObject private var viewModel: LocationSearchViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.searchResults, id: \.self) { completionResult in
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(completionResult.title)
                                .font(.system(size: 16.0))
                            Text(completionResult.subtitle)
                                .font(.system(size: 12.0))
                            Divider()
                        }
                        .padding(.bottom, 8.0)
                    }
                }
                .padding()
            }
            .navigationTitle("Search location")
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "write here"
        )
    }

    init(viewModel: LocationSearchViewModel) {
        self.viewModel = viewModel
    }
}
