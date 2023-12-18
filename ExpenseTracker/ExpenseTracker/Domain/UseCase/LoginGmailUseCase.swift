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
    func signOut() throws -> Void
    func getCurrentUser() -> GIDGoogleUser?
}

final class LoginGmailUseCase: LoginGmailUseCaseProtocol {

    func checkAuthStatus() -> Observable<GIDGoogleUser> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return Future<GIDGoogleUser, Error> { [weak self] promise in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        NSLog("Gmail auth error: %@", error as NSError)
                        promise(.failure(CommonError.noPreviousAccountFound))
                    } else if let user = user {
                        // Goole sign in done, start firebase auth
                        self?.signInToFirebase(user: user) { isSuccess in
                            if isSuccess {
                                promise(.success(user))
                            } else {
                                promise(.failure(CommonError.firebaseSignInFailed))
                            }
                        }
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
        GIDSignIn.sharedInstance.currentUser != nil
    }

    func getCurrentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }

    func signIn() -> Observable<GIDGoogleUser> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return Future<GIDGoogleUser, Error> { [weak self] promise in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        NSLog("Gmail auth error: %@", error as NSError)
                        promise(.failure(CommonError.noPreviousAccountFound))
                    } else if let user = user {
                        // Goole sign in done, start firebase auth
                        self?.signInToFirebase(user: user) { isSuccess in
                            if isSuccess {
                                promise(.success(user))
                            } else {
                                promise(.failure(CommonError.firebaseSignInFailed))
                            }
                        }
                    } else {
                        let unknownError = CommonError.authError
                        promise(.failure(unknownError))
                    }
                }
            }
            .eraseToAnyPublisher()
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }
            let configuration = GIDConfiguration(clientID: clientID)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }
            guard let rootViewController = windowScene.windows.first?.rootViewController else {
                return Fail(error: CommonError.authError).eraseToAnyPublisher()
            }
            GIDSignIn.sharedInstance.configuration = configuration
            return Future<GIDGoogleUser, Error> { [weak self] promise in
                GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                    if let error = error {
                        NSLog("Gmail auth error: %@", error as NSError)
                        promise(.failure(error))
                    } else if let result = result {
                        // Goole sign in done, start firebase auth
                        self?.signInToFirebase(user: result.user) { isSuccess in
                            if isSuccess {
                                promise(.success(result.user))
                            } else {
                                promise(.failure(CommonError.firebaseSignInFailed))
                            }
                        }
                    } else {
                        let unknownError = CommonError.authError
                        promise(.failure(unknownError))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          NSLog("Error signing out: %@", signOutError)
            throw CommonError.signOutFailed
        }
    }

    private func signInToFirebase(user: GIDGoogleUser,  isSuccess: @escaping (Bool) -> Void) {
        guard let idToken = user.idToken?.tokenString else {
            isSuccess(false)
            return
        }
        let firebaseCredential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        Auth.auth().signIn(with: firebaseCredential) { fbResult, fbError in
            if let fbError = fbError {
                NSLog("Firebase auth error: %@", fbError as NSError)
                isSuccess(false)
            } else if let _ = fbResult {
                // Firebase Sign in done
                isSuccess(true)
            } else {
                isSuccess(false)
            }
        }
    }
}
