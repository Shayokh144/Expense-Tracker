//
//  AuthState.swift
//  ExpenseTracker
//
//  Created by Taher on 15/12/23.
//

import Foundation

enum AuthState: Equatable {

    case loading
    case signedOut
    case signedIn
    case error(message: String)
}
