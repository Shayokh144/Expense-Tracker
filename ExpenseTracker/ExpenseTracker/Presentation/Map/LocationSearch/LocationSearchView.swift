//
//  LocationSearchScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 22/11/23.
//

import FlowStacks
import SwiftUI

struct LocationSearchScreen: View {

    @ObservedObject private var viewModel: LocationSearchViewModel
    @EnvironmentObject var navigator: AppCoordinatorViewModel

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
                        .background(Color.clear)
                        .onTapGesture {
                            viewModel.onTapPlaceSearchResult(result: completionResult)
                        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // BACK BUTTON
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navigator.goBack()
                }) {
                    Label("Back", systemImage: "arrow.left.circle")
                }
            }
        }
    }

    init(viewModel: LocationSearchViewModel) {
        self.viewModel = viewModel
    }
}
