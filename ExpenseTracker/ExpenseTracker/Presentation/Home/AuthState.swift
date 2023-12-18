//
//  AuthState.swift
//  ExpenseTracker
//
//  Created by Taher on 15/12/23.
//

import Foundation

enum AuthState {

    case loading
    case signedOut
    case signedIn(name: String)
    case error(message: String)
}
