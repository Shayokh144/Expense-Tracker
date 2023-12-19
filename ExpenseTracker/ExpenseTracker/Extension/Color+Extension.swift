//
//  Color+Extension.swift
//  ExpenseTracker
//
//  Created by Taher on 28/11/23.
//

import SwiftUI

extension Color {

    init(hexString: String, alpha: Double = 1.0) {
        guard let hexValue = UInt(String(hexString.suffix(6)), radix: 16) else {
            NSLog("Color Error: \(hexString) is an invalid color code, returning default black color")
            self.init(hexCode: 0x000000)
            return
        }
        self.init(hexCode: hexValue, alpha)
    }

    init(hexCode: UInt, _ alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hexCode >> 16) & 0xFF) / 255,
            green: Double((hexCode >> 8) & 0xFF) / 255,
            blue: Double(hexCode & 0xFF) / 255,
            opacity: alpha
        )
    }
}

