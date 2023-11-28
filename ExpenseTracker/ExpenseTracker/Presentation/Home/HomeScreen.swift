//
//  HomeScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import FlowStacks
import SwiftUI

struct HomeScreen: View {

    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @ObservedObject private var viewModel: HomeViewModel

    private var loginGmailButton: some View {
        Button {

        } label: {
            Text("Login with Gmail")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#AD2533"),
                textColor: .white
            )
        )
    }

    private var searchLocationButton: some View {
        Button {
            navigator.goToSearchLocationView()
        } label: {
            Text("Search location in map")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#2529AD"),
                textColor: .white
            )
        )
    }

    private var seeCurrentLocationButton: some View {
        Button {
            navigator.goToCurrentLocationView()
        } label: {
            Text("See current location in map")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: "#2529AD"),
                textColor: .white
            )
        )
    }

    var body: some View {
        VStack {
            loginGmailButton
            searchLocationButton
            seeCurrentLocationButton
        }
        .padding()
    }

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
}
