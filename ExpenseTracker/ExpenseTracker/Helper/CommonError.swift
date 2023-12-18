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
    case unknown

    var localizedDescription: String {
        switch self {
        case .authError:
            return "Authentication failed"
        case .noPreviousAccountFound:
            return "No previous account found"
        case .unknown:
            return "Unknown error occured"
        }
    }
}
