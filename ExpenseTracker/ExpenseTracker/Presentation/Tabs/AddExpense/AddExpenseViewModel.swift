//
//  AddExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Combine
import Foundation

final class AddExpenseViewModel: ObservableObject {

    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase

    init(firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase()) {
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
    }

    func saveExpenseList() {
        firebaseRealtimeDBUseCase.postExpanse(expenseList: ExpenseList.dummy) { isSuccess in
            print("XYZ POST RESULT: \(isSuccess)")
        }
    }
}
