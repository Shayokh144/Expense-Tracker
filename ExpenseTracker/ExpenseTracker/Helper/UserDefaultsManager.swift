//
//  UserDefaultsManager.swift
//  ExpenseTracker
//
//  Created by Taher on 14/11/23.
//

import Foundation

protocol UserDefaultsManagerProtocol {

    func save<T>(data: T, for key: String)
    func getInt(for key: String) -> Int
    func getString(for key: String) -> String?
    func getBool(for key: String) -> Bool
    func deleteData(for key: String)
    func isKeyExist(for key: String) -> Bool
    func isFirstInstall() -> Bool
}

final class UserDefaultsManager: UserDefaultsManagerProtocol {

    private let storage: UserDefaults

    init(storage: UserDefaults = UserDefaults.standard) {
        self.storage = storage
    }

    public func save<T>(data: T, for key: String) {
        storage.setValue(data, forKey: key)
    }

    public func getInt(for key: String) -> Int {
        storage.integer(forKey: key)
    }

    public func getString(for key: String) -> String? {
        storage.string(forKey: key)
    }

    public func getBool(for key: String) -> Bool {
        storage.bool(forKey: key)
    }

    public func deleteData(for key: String) {
        storage.removeObject(forKey: key)
    }

    public func isKeyExist(for key: String) -> Bool {
        storage.object(forKey: key) != nil
    }

    public func isFirstInstall() -> Bool {
        let isFirstInstall = !isKeyExist(
            for: UserDefaults.Keys.isFristRun
        )
        if isFirstInstall {
            save(
                data: true,
                for: UserDefaults.Keys.isFristRun
            )
        }
        return isFirstInstall
    }
}
