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
    private let onSignInSuccess: (User) -> Void

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

    var body: some View {
        VStack {
            switch viewModel.authState {
            case .loading:
                ProgressView()
            case .signedOut:
                signInButton
            case .signedIn:
                // TODO: Remove dummy
                Text("Sign in success")
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
        .onChange(of: viewModel.authState) { state in
            if state == .signedIn {
                if let user = viewModel.getUser() {
                    onSignInSuccess(user)
                }
            }
        }
    }

    init(viewModel: HomeViewModel, onSignInSuccess: @escaping (User) -> Void) {
        self.viewModel = viewModel
        self.onSignInSuccess = onSignInSuccess
    }
}
