//
//  LoginGmailUseCase.swift
//  ExpenseTracker
//
//  Created by Taher on 29/11/23.
//

import Combine
import GoogleSignIn
import Firebase

protocol LoginGmailUseCaseProtocol {

    func isSignedIn() -> Bool
    func checkAuthStatus() -> Observable<GIDGoogleUser>
    func signIn() -> Observable<GIDGoogleUser>
    func signOut() -> Void
    func getCurrentUser() -> GIDGoogleUser?
}

final class LoginGmailUseCase: LoginGmailUseCaseProtocol {

    func checkAuthStatus() -> Observable<GIDGoogleUser> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return Future<GIDGoogleUser, Error> { promise in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let _ = error {
                        promise(.failure(CommonError.noPreviousAccountFound))
                    } else if let user = user {
                        promise(.success(user))
                    } else {
                        let unknownError = CommonError.authError
                        promise(.failure(unknownError))
                    }
                }
            }
            .eraseToAnyPublisher()
        } else {
            return Fail(error: CommonError.noPreviousAccountFound).eraseToAnyPublisher()
        }
    }

    func isSignedIn() -> Bool {
        GIDSignIn.sharedInstance.currentUser == nil
    }

    func getCurrentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }

    func signIn() -> Observable<GIDGoogleUser> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return Future<GIDGoogleUser, Error> { promise in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let _ = error {
                        promise(.failure(CommonError.noPreviousAccountFound))
                    } else if let user = user {
                        promise(.success(user))
                    } else {
                        let unknownError = CommonError.authError
                        promise(.failure(unknownError))
                    }
                }
            }
            .eraseToAnyPublisher()
        } else {
            // 2
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }

            // 3
            let configuration = GIDConfiguration(clientID: clientID)

            // 4
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }

            // 5
            GIDSignIn.sharedInstance.configuration = configuration
            return Future<GIDGoogleUser, Error> { promise in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let result = result {
                        promise(.success(result.user))
                    } else {
                        let unknownError = CommonError.authError
                        promise(.failure(unknownError))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}
