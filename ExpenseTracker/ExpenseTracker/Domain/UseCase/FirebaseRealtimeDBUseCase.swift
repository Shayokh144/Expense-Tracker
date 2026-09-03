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
    private var lastFetchedAnalyticsDataKey: String?
    private var databaseReference: DatabaseReference?

    private init() {
        lastFetchedDataKey = nil
        lastFetchedAnalyticsDataKey = nil
        databaseReference = nil
    }

    func clearDBSession(isSingedIn: Bool) {
        NSLog("clearDBSession: \(isSingedIn)")
        lastFetchedDataKey = nil
        lastFetchedAnalyticsDataKey = nil
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

    // MARK: - Update / Delete data in FBRDB

    func updateExpenseList(
        expenseList: ExpenseList,
        isSuccessCompletion: @escaping (Bool) -> Void
    ) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            isSuccessCompletion(false)
            return
        }
        guard let id = expenseList.id, !id.isEmpty else {
            NSLog("Expense list id not found")
            isSuccessCompletion(false)
            return
        }
        if expenseList.expenses.isEmpty {
            NSLog("expenseList.expenses isEmpty")
            isSuccessCompletion(false)
            return
        }
        do {
            let data = try encoder.encode(expenseList)
            let json = try JSONSerialization.jsonObject(with: data)
            databasePath.child(id).setValue(json) { error, _ in
                if let error = error {
                    NSLog("Update method error: \(error)")
                    isSuccessCompletion(false)
                    return
                }
                isSuccessCompletion(true)
            }
        } catch let error {
            NSLog("Update method error: \(error)")
            isSuccessCompletion(false)
        }
    }

    func deleteExpenseList(
        id: String,
        isSuccessCompletion: @escaping (Bool) -> Void
    ) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            isSuccessCompletion(false)
            return
        }
        guard !id.isEmpty else {
            NSLog("Expense list id not found")
            isSuccessCompletion(false)
            return
        }
        databasePath.child(id).removeValue { error, _ in
            if let error = error {
                NSLog("Delete method error: \(error)")
                isSuccessCompletion(false)
                return
            }
            isSuccessCompletion(true)
        }
    }

    // MARK: - Get data from FBRDB

    
    /// This method will fetch expense list using id
    func getExpenseList(id: String, completion: @escaping (ExpenseList?) -> Void) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            completion(nil)
            return
        }
        databasePath.child(id).observeSingleEvent(of: .value) { [weak self] snapshot  in
            let dataModel = self?.getExpenseModel(snapshot: snapshot)
            completion(dataModel)
        }
    }
    
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
        forAnalytics: Bool = false,
        queryLimit: UInt,
        completion: @escaping ([ExpenseList]?) -> Void
    ) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            completion(nil)
            return
        }
        let queryGet = getDataBaseQuery(
            forAnalytics: forAnalytics,
            databasePath: databasePath,
            queryLimit: queryLimit
        )
        
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
                if forAnalytics {
                    self.lastFetchedAnalyticsDataKey = firstChild.key
                } else {
                    self.lastFetchedDataKey = firstChild.key
                }
            }
//            print("snap cnt: \(dataModels.count)")
            completion(dataModels)
        }
    }

    /// Fetches the most recent expense lists without using pagination cursor state.
    func getRecentExpenseLists(
        queryLimit: UInt,
        completion: @escaping ([ExpenseList]?) -> Void
    ) {
        guard let databasePath = databaseReference else {
            NSLog("Database path not found")
            completion(nil)
            return
        }

        databasePath
            .queryOrdered(byChild: "id")
            .queryLimited(toLast: queryLimit)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                var dataModels: [ExpenseList] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        if let dataModel = self.getExpenseModel(snapshot: snapshot) {
                            dataModels.append(dataModel)
                        }
                    }
                }
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
    
    private func getDataBaseQuery(
        forAnalytics: Bool,
        databasePath: DatabaseReference,
        queryLimit: UInt
    ) -> DatabaseQuery {
        if forAnalytics {
            if let lastFetchedAnalyticsDataKey = lastFetchedAnalyticsDataKey {
                return databasePath
                    .queryOrderedByKey()
                    .queryEnding(atValue: lastFetchedAnalyticsDataKey) // if query ordered by key
                    .queryLimited(toLast: queryLimit)
            } else {
                return databasePath
                    .queryOrdered(byChild: "id")
                    .queryLimited(toLast: queryLimit)
            }
        }
        if let lastFetchedDataKey = lastFetchedDataKey {
            return databasePath
                .queryOrderedByKey()
                .queryEnding(atValue: lastFetchedDataKey) // if query ordered by key
                .queryLimited(toLast: queryLimit)
        } else {
            return databasePath
                .queryOrdered(byChild: "id")
                .queryLimited(toLast: queryLimit)
        }
    }

    deinit {
        databaseReference?.removeAllObservers()
    }
}
