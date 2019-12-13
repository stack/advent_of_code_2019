//
//  main.swift
//  Day 04
//
//  Created by Stephen H. Gerstacker on 2019-12-04.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

let input = Data.input

// Part 1

func <= (lhs: [UInt8], rhs: [UInt8]) -> Bool {
    for pair in zip(lhs, rhs) {
        if pair.0 < pair.1 {
            return true
        } else if pair.0 > pair.1 {
            return false
        }
    }

    return true
}

func increment(_ value: inout [UInt8]) {
    for idx in (0 ..< value.count).reversed() {
        if value[idx] < 9 {
            value[idx] += 1
            break
        } else {
            value[idx] = 0
        }
    }

    nextValid(&value)
}

func nextValid(_ value: inout [UInt8]) {
    for idx in (0 ..< value.count - 1) {
        if value[idx] <= value[idx + 1] {
            continue
        }

        for correctIdx in (idx ..< value.count) {
            value[correctIdx] = value[idx]
        }
    }
}

func isValid(_ value: [UInt8]) -> Bool {
    for idx in 0 ..< (value.count - 1) {
        if value[idx] == value[idx + 1] {
            return true
        }
    }

    return false
}

func isExtraValid(_ value: [UInt8]) -> Bool {
    var sums = [UInt8](repeating: 0, count: 10)

    for v in value {
        sums[Int(v)] += 1
    }

    for sum in sums {
        if sum == 2 {
            return true
        }
    }

    return false
}

let numbers = input.split(separator: "-").map { String($0) }
let lower = numbers[0].map { UInt8(String($0), radix: 10)! }
let upper = numbers[1].map { UInt8(String($0), radix: 10)! }

var current = lower
nextValid(&current)

var count = 0
var extraCount = 0

while current <= upper {
    var extra = ""

    if isValid(current) {
        count += 1
        extra += " *"
    }

    if isExtraValid(current) {
        extraCount += 1
        extra += " +"
    }

    print("\(current)\(extra)")

    increment(&current)
}

print("Valids: \(count)")
print("Extra Valids: \(extraCount)")
