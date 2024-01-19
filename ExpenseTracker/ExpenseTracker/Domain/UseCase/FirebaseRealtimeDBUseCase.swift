//
//  FirebaseRealtimeDBUseCase.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import FirebaseAuth
import FirebaseDatabase

final class FirebaseRealtimeDBUseCase {

    static let shared = FirebaseRealtimeDBUseCase()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var lastFetchedDataKey: String?
    private var databaseReference: DatabaseReference?

    private init() {
        lastFetchedDataKey = nil
        databaseReference = nil
    }

    func clearDBSession(isSingedIn: Bool) {
        NSLog("clearDBSession: \(isSingedIn)")
        lastFetchedDataKey = nil
        if isSingedIn {
            databaseReference = getDatabaseReference()
        } else {
            databaseReference?.removeAllObservers()
            databaseReference = nil
        }
    }

    // MARK: - Post data to FBRDB

    func postExpanse(
        expenseList: ExpenseList,
        isSuccessCompletion: @escaping (Bool) -> Void
    ) {
        guard let databasePath = databaseReference else {
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
            clearDBSession(isSingedIn: true)
            isSuccessCompletion(true)
        } catch let error {
            NSLog("Post method error: \(error)")
            isSuccessCompletion(false)
        }
    }

    // MARK: - Get data from FBRDB

    /// This method will fetch expense list one by one, from oldest to newest
    func getExpenses(completion: @escaping (ExpenseList?) -> Void) {
        guard let databasePath = databaseReference else {
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
     After reading last 10, it will read second last 10 records.
     For example, if total 100 records, first it will read 90 to 100, then it will read 80-89 and so on.
     */
    func getLatestExpenseLists(
        queryLimit: UInt,
        completion: @escaping ([ExpenseList]?) -> Void
    ) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            completion(nil)
            return
        }
        var queryGet: DatabaseQuery
        if let lastFetchedDataKey = lastFetchedDataKey {
            queryGet = databasePath
                .queryOrderedByKey()
                .queryEnding(atValue: lastFetchedDataKey) // if query ordered by key
                .queryLimited(toLast: queryLimit)
        } else {
            queryGet = databasePath
                .queryOrdered(byChild: "id")
                .queryLimited(toLast: queryLimit)
        }

        queryGet.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            var dataModels: [ExpenseList] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let dataModel = self.getExpenseModel(snapshot: snapshot) {
                        dataModels.append(dataModel)
                    }
                }
            }
            if let firstChild = snapshot.children.allObjects.first as? DataSnapshot {
                self.lastFetchedDataKey = firstChild.key
            }
//            print("snap cnt: \(dataModels.count)")
            completion(dataModels)
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

    private func getDatabaseReference() -> DatabaseReference? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        NSLog("USER: \(String(describing: Auth.auth().currentUser?.email))")
        let database = Database.database()
        let ref = database
            .reference()
            .child("users/\(uid)/expenseLists")
        ref.keepSynced(true)
        return ref
    }

    deinit {
        databaseReference?.removeAllObservers()
    }
}
