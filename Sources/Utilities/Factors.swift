//
//  Factors.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public extension SignedInteger {

    func factors() -> [Self] {
        var currentFactor: Self = 2
        var currentValue = self
        var factors: [Self] = []

        while currentFactor <= currentValue {
            if currentValue % currentFactor == 0 {
                factors.append(currentFactor)
                currentValue /= currentFactor
            } else {
                currentFactor += 1
            }
        }

        return factors
    }
}
