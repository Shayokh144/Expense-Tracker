//
//  Date+Extension.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Foundation

extension Date {

    static let currentDateString: String = {
        let currentDate = Date()
        let dateString = DateFormatter.fullDateTimeFormat.string(from: currentDate)
        return dateString
    }()
    
    static func daysBetween(_ start: Date, _ end: Date) -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day
    }
}
