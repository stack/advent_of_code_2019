//
//  Data.swift
//  Day 12
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities
import simd

struct Data {

    static let sample1 = [
        SIMD3<Int32>(-1, 0, 2),
        SIMD3<Int32>(2, -10, -7),
        SIMD3<Int32>(4, -8, 8),
        SIMD3<Int32>(3, 5, -1),
    ]

    static let sampleSteps1 = 10

    static let sample2 = [
        SIMD3<Int32>(-8, -10, 0),
        SIMD3<Int32>(5, 5, 10),
        SIMD3<Int32>(2, -7, 3),
        SIMD3<Int32>(9, -8, -3)
    ]

    static let sampleSteps2 = 100

    static let input = [
        SIMD3<Int32>(-3, 10, -1),
        SIMD3<Int32>(-12, -10, -5),
        SIMD3<Int32>(-9, 0, 10),
        SIMD3<Int32>(7, -5, -3)
    ]

    static let inputSteps = 1000

}
