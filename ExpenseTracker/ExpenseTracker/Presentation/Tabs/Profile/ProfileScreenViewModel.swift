//
//  ProfileScreenViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 19/12/23.
//

import Combine
import Foundation

final class ProfileScreenViewModel: ObservableObject {

    private let loginGmailUseCase: LoginGmailUseCaseProtocol
    let user: User
    private var cancellable = Set<AnyCancellable>()
    @Published var authState: AuthState = .signedIn


    init(user: User, loginGmailUseCase: LoginGmailUseCaseProtocol = LoginGmailUseCase()) {
        self.user = user
        self.loginGmailUseCase = loginGmailUseCase
    }

    func onTapSignOut() {
        do {
            try loginGmailUseCase.signOut()
            authState = .signedOut
        } catch let error {
            authState = .error(message: error.localizedDescription)
        }
    }
}
