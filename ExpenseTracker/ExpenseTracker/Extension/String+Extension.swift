//
//  String+Extension.swift
//  ExpenseTracker
//
//  Created by Taher on 16/1/24.
//

import Foundation

extension String {

    var currencySymbol: String {
        if self == "BDT" {
            return "৳"
        } else if self == "THB" {
            return "฿"
        }
        return "$"
    }

    var yearMonthKey: String {
        let parts = split(separator: "-")
        guard parts.count >= 2 else { return self }
        return "\(parts[0])-\(parts[1])"
    }
}
