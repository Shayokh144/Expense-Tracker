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

    var body: some View {
        VStack {
            Text(viewModel.user.name)
                .font(.title2)
            Text(viewModel.user.email)
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
