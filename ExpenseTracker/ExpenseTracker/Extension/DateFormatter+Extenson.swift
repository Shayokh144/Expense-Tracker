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
}
