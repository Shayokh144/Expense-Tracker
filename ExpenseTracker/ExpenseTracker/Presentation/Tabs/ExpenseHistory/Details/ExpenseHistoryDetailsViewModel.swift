//
//  ExpenseHistoryDetailsViewModel.swift
//  ExpenseTracker
//
//  Created by Taher on 17/4/24.
//

import Foundation

final class ExpenseHistoryDetailsViewModel: ObservableObject {
    
    @Published var expenseList: ExpenseList?
    private let id: String
    private let firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase
    
    init(
        id: String,
        firebaseRealtimeDBUseCase: FirebaseRealtimeDBUseCase = FirebaseRealtimeDBUseCase.shared
    ) {
        self.id = id
        self.firebaseRealtimeDBUseCase = firebaseRealtimeDBUseCase
    }
    
    func loadData() {
        firebaseRealtimeDBUseCase.getExpenseList(id: id) { [weak self] data in
            self?.expenseList = data
        }
    }
}
