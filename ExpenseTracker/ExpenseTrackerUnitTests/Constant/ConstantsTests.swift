//
//  ConstantsTests.swift
//  ExpenseTrackerUnitTests
//
//  Created by Taher's nimble macbook on 30/5/24.
//

import XCTest
@testable import ExpenseTracker

final class ConstantsTests: XCTestCase {

    func testBaseTHB() throws {
        let bdtRate = Constants.AppData.currencyConversionRate(
            fromCurrency: "THB",
            toCurrency: "BDT"
        )
        let thbValue = 1000.0
        let bdtValue = thbValue * Constants.AppData.oneThbInBdt
        XCTAssert(thbValue * bdtRate == bdtValue)
    }
    
    func testBaseBDT() throws {
        let thbRate = Constants.AppData.currencyConversionRate(
            fromCurrency: "BDT",
            toCurrency: "THB"
        )
        let bdtValue = 1000.0
        let thbValue = bdtValue / Constants.AppData.oneThbInBdt
        print("XYZ thb: \(thbValue) res: \(bdtValue * thbRate)")
        XCTAssert(bdtValue * thbRate == thbValue)
    }
}
