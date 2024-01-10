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
    private let decoder = JSONDecoder()
    private var lastFetchedDataKey: String?

    // MARK: - Post data to FBRDB

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

    // MARK: - Get data from FBRDB

    /// This method will fetch expense list one by one, from oldest to newest
    func getExpenses(completion: @escaping (ExpenseList?) -> Void) {
        guard let databasePath = databasePath else {
            NSLog("Database path not found")
            completion(nil)
            return
        }
        databasePath.observe(.childAdded) { [weak self] snapshot  in
            let dataModel = self?.getExpenseModel(snapshot: snapshot)
            completion(dataModel)
        }
    }

    /**
     This method will fetch latest data based on queryLimit. Let, queryLimit = 10
     After reading last 10, it will read second last 10 records again.
     For example, if total 100 records, first it will read 90 to 100, then it will read 80-89 and so on.
     */
    func getLatesExpenses(
        queryLimit: UInt = 1,
        completion: @escaping (ExpenseList?) -> Void
    ) {
        guard let databasePath = databasePath else {
            NSLog("Database path not found")
            completion(nil)
            return
        }
        if lastFetchedDataKey != nil {
            let mostRecent = databasePath
                .queryEnding(beforeValue: nil, childKey: lastFetchedDataKey)
                .queryLimited(toLast: queryLimit)
            mostRecent.observe(.childAdded) { [weak self] snapshot  in
                self?.lastFetchedDataKey = snapshot.key
                let dataModel = self?.getExpenseModel(snapshot: snapshot)
                completion(dataModel)
            }
        } else {
            let mostRecent = databasePath.queryLimited(toLast: queryLimit)
            mostRecent.observe(.childAdded) { [weak self] snapshot  in
                self?.lastFetchedDataKey = snapshot.key
                let dataModel = self?.getExpenseModel(snapshot: snapshot)
                completion(dataModel)
            }
        }
    }

    // MARK: - Model conversion

    private func getExpenseModel(snapshot: DataSnapshot) ->  ExpenseList? {
        guard var json = snapshot.value as? [String: Any]
        else {
            return nil
        }
        json["id"] = snapshot.key
        do {
            let expenseListData = try JSONSerialization.data(withJSONObject: json)
            let expenseList = try self.decoder.decode(ExpenseList.self, from: expenseListData)
            return expenseList
        } catch let error {
            NSLog("Data conversion error: \(error)")
        }
        return nil
    }

    deinit {
        databasePath?.removeAllObservers()
    }
}
