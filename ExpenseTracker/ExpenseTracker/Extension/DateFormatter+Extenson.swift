//
//  DateFormatter+Extenson.swift
//  ExpenseTracker
//
//  Created by Taher on 27/12/23.
//

import Foundation

extension DateFormatter {

    static let fullDateTimeFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()

    /// Result: "12 Dec 2023, 3:30 PM"
    static let displayDateTimeFormat: DateFormatter = {
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "d MMM yyyy, h:mm a"
        displayDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return displayDateFormatter
    }()
}
