//
//  HomeViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import Combine
import Foundation
import FirebaseAuth

final class HomeViewModel: ObservableObject {

    private let loginGmailUseCase: LoginGmailUseCaseProtocol
    
    @Published var authState: AuthState = .signedOut
    private var cancellable = Set<AnyCancellable>()

    init(loginGmailUseCase: LoginGmailUseCaseProtocol = LoginGmailUseCase()) {
        self.loginGmailUseCase = loginGmailUseCase
    }

    func checkAuthSate() {
        authState = .loading
        if let user = Auth.auth().currentUser {
            print("XYZ UID:  \(user.uid)")
            self.authState = .signedIn
            return
        }
        loginGmailUseCase.checkAuthStatus()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        if let newErr = error as? CommonError {
                            print(newErr.localizedDescription)
                            self?.authState = .error(message: newErr.localizedDescription)
                        } else {
                            self?.authState = .error(message: CommonError.unknown.localizedDescription)
                        }
                    case .finished:
                        NSLog("Finished sign in flow")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.authState = .signedIn
                }
            )
            .store(in: &cancellable)
    }

    func onTapSignIn() {
        authState = .loading
        loginGmailUseCase.signIn()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case let .failure(error):
                        if let newErr = error as? CommonError {
                            print(newErr.localizedDescription)
                            self?.authState = .error(message: newErr.localizedDescription)
                        } else {
                            self?.authState = .error(message: CommonError.unknown.localizedDescription)
                        }
                    case .finished:
                        NSLog("Finished sign in flow")
                    }
                },
                receiveValue: { [weak self] user in
                    print("USER: \(user)")
                    self?.authState = .signedIn
                }
            )
            .store(in: &cancellable)
    }

    func onTapSignOut() {
        do {
            try loginGmailUseCase.signOut()
            authState = .signedOut
        } catch let error {
            authState = .error(message: error.localizedDescription)
        }
    }

    func isSignedIn() -> Bool {
        loginGmailUseCase.isSignedIn()
    }

    func getUser() -> User? {
        if let fUser = Auth.auth().currentUser {
            return User(
                id: fUser.uid,
                name: fUser.displayName ?? "No name found",
                email: fUser.email ?? "No email found"
            )
        }
        guard let gUser = loginGmailUseCase.getCurrentUser() else {
            return nil
        }
        guard let id = gUser.userID, let profile = gUser.profile else {
            return nil
        }
        return User(
            id: id,
            name: profile.name,
            email: profile.email
        )
    }
}
