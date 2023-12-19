//
//  ProfileScreen.swift
//  ExpenseTracker
//
//  Created by Taher on 18/12/23.
//

import SwiftUI

struct ProfileScreen: View {
    
    @EnvironmentObject var navigator: AppCoordinatorViewModel
    @ObservedObject private var viewModel: ProfileScreenViewModel

    private let onSignOutSuccess: () -> Void

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
            Text(viewModel.user.name)
                .font(.title2)
            Text(viewModel.user.email)
            searchLocationButton
            seeCurrentLocationButton
            signOutButton
        }
        .padding()
        .onChange(of: viewModel.authState) { state in
            if state == .signedOut {
                onSignOutSuccess()
            }
        }
    }

    init(viewModel: ProfileScreenViewModel, onSignOutSuccess: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSignOutSuccess = onSignOutSuccess
    }
}
