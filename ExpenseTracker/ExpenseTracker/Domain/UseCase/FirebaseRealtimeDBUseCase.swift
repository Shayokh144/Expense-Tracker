//
//  FirebaseRealtimeDBUseCase.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import FirebaseAuth
import FirebaseDatabase

final class FirebaseRealtimeDBUseCase {

    private lazy var databasePath: DatabaseReference? = {
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/expenseLists")
      return ref
    }()

    private let encoder = JSONEncoder()

    func postExpanse(
        expenseList: ExpenseList,
        isSuccessCompletion: @escaping (Bool) -> Void
    ) {
        guard let databasePath = databasePath else {
            NSLog("Database path not found")
            isSuccessCompletion(false)
            return
        }

        if expenseList.expenses.isEmpty {
            NSLog("expenseList.expenses isEmpty")
            return
        }
        do {
            let data = try encoder.encode(expenseList)
            let json = try JSONSerialization.jsonObject(with: data)
            databasePath.childByAutoId()
                .setValue(json)
            isSuccessCompletion(true)
        } catch let error {
            NSLog("Post method error: \(error)")
            isSuccessCompletion(false)
        }
    }
}
