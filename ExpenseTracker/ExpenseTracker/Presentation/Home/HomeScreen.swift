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

    private var signInButton: some View {
        Button {
            viewModel.onTapSignIn()
        } label: {
            Text(Constants.AppText.signInGmail)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.redButtonColor),
                textColor: .white
            )
        )
    }

    private var signOutButton: some View {
        Button {
            viewModel.onTapSignOut()
        } label: {
            Text(Constants.AppText.signOut)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.redButtonColor),
                textColor: .white
            )
        )
    }

    private var searchLocationButton: some View {
        Button {
            navigator.goToSearchLocationView()
        } label: {
            Text(Constants.AppText.searchLocationMap)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    private var seeCurrentLocationButton: some View {
        Button {
            navigator.goToCurrentLocationView()
        } label: {
            Text(Constants.AppText.seeCurrentLocationMap)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            TextButtonStyle(
                backgroundColor: Color(hexString: Constants.AppColors.blueButtonColor),
                textColor: .white
            )
        )
    }

    var body: some View {
        VStack {
            switch viewModel.authState {
            case .loading:
                ProgressView()
            case .signedOut:
                signInButton
            case let .signedIn(name):
                Text("Hi: \(name)")
                    .foregroundColor(.white)
                searchLocationButton
                seeCurrentLocationButton
                signOutButton
            case let .error(message):
                Text(message)
                    .foregroundColor(.red)
                signInButton
            }
        }
        .padding()
        .onAppear {
            viewModel.checkAuthSate()
        }
    }

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
}
