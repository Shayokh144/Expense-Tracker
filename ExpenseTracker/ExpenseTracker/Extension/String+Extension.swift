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
}
