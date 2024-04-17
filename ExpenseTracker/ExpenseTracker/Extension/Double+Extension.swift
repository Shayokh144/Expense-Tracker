//
//  Double+Extension.swift
//  ExpenseTracker
//
//  Created by Taher on 11/1/24.
//

import Foundation

extension Double {
    
    var fractionTwoDigitString:String {
        return String(format: "%.2f", self)
    }
}
