//
//  FactorTests.swift
//  UtilitiesTests
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest

@testable import Utilities

class FactorTests: XCTestCase {

    func testFactors() {
        var result = 18.factors()
        XCTAssertEqual(result, [2, 3, 3])

        result = 28.factors()
        XCTAssertEqual(result, [2, 2, 7])

        result = 44.factors()
        XCTAssertEqual(result, [2, 2, 11])
    }
}
