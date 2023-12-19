//
//  CommonError.swift
//  ExpenseTracker
//
//  Created by Taher on 15/12/23.
//

import Foundation

enum CommonError: LocalizedError {

    case authError
    case noPreviousAccountFound
    case signOutFailed
    case firebaseSignInFailed
    case unknown

    var localizedDescription: String {
        switch self {
        case .authError:
            return "Authentication failed for unknown reason"
        case .noPreviousAccountFound:
            return "No previous account found"
        case .signOutFailed:
            return "Sign out process failed, try again"
        case .firebaseSignInFailed:
            return "Sign in to firebase failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
