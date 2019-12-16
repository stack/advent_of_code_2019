//
//  main.swift
//  Day 16
//
//  Created by Stephen H. Gerstacker on 2019-12-16.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data1 = Data.input
let phases1 = Data.inputPhases
let skip1 = true

func generatePattern(position: Int, length: Int) -> [Int] {
    precondition(position > 0)

    let part1 = [Int](repeating: 0, count: position)
    let part2 = [Int](repeating: 1, count: position)
    let part3 = [Int](repeating: 0, count: position)
    let part4 = [Int](repeating: -1, count: position)

    let segment = part1 + part2 + part3 + part4

    var pattern = segment

    while pattern.count <= length {
        pattern += segment
    }

    pattern.removeFirst()

    return pattern
}

if !skip1 {
    // Split the string in to numbers
    let digits = data1.map { Int(String($0))! }

    print("Input signal: \(digits)")

    // Generate the pattern lists
    let patterns = (0 ..< data1.count).map {
        generatePattern(position: $0 + 1, length: digits.count)
    }

    // MARK: - Part 1

    // Run through each phase
    var currentDigits = digits

    for phaseIdx in 0 ..< phases1 {
        for digitIdx in 0 ..< digits.count / 2 {
            let pattern = patterns[digitIdx]

            let pairs = zip(currentDigits, pattern)

            currentDigits[digitIdx] = pairs.reduce(0) { $0 + $1.0 * $1.1 }
            currentDigits[digitIdx] = abs(currentDigits[digitIdx]) % 10
        }

        for digitIdx in (currentDigits.count / 2 ..< currentDigits.count - 1).reversed() {
            currentDigits[digitIdx] = (currentDigits[digitIdx] + currentDigits[digitIdx + 1]) % 10
        }

        print("After \(phaseIdx + 1) phases: \(currentDigits)")
    }

    let finalDigits = currentDigits[0 ..< 8].reduce("") { $0 + String($1) }
    print("First 8 digits after \(phases1) phases: \(finalDigits)")
}

// MARK: - Part 2

let data2 = Data.input
let phases2 = Data.inputPhases
let skip2 = false

if !skip2 {
    // Split the string in to numbers
    let digits = data2.map { Int(String($0))! }

    print("Input signal: \(digits) x 10,000")

    let messageOffsetString = digits[0 ..< 7]
        .map { String($0) }
        .joined()
    let messageOffset = Int(messageOffsetString)!

    var currentDigits: [Int] = []

    for _ in 0 ..< 10_000 {
        currentDigits += digits
    }

    print("Message Offset: \(messageOffset) in \(currentDigits.count)")

    for _ in 0 ..< phases2 {
        for digitIdx in (messageOffset ..< currentDigits.count - 1).reversed() {
            currentDigits[digitIdx] = (currentDigits[digitIdx] + currentDigits[digitIdx + 1]) % 10
        }
    }

    let lowerBound = messageOffset
    let upperBound = messageOffset + 8

    let message = currentDigits[lowerBound ..< upperBound].map { String($0) }.joined()
    print("Message: \(message)")
}
