//
//  main.swift
//  Day 01
//
//  Created by Stephen H. Gerstacker on 2019-12-01.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

func allFuelRequired(_ mass: Int) -> [Int] {
    var all: [Int] = []

    var current = fuelRequired(mass)

    while current > 0 {
        all.append(current)
        current = fuelRequired(current)
    }

    return all
}

func fuelRequired(_ mass: Int) -> Int {
    return (mass / 3) - 2
}

let masses = lineGenerator(fileHandle: .standardInput).map { Int($0)! }
let fuels = masses.map(fuelRequired)
let allFuels = masses.map(allFuelRequired)

let total = fuels.reduce(0, +)
let allTotals = allFuels.reduce(0) { (acc: Int, value: [Int]) -> Int in
    acc + value.reduce(0, +)
}

print("")
print("## Fuel")
print("")

for pair in zip(masses, fuels) {
    print("\(pair.0) -> \(pair.1)")
}

print("")
print("## All Fuels")
print("")

for pair in zip(masses, allFuels) {
    print("\(pair.0) -> \(pair.1)")
}

print("")
print("## Totals")
print("")

print("Total: \(total)")
print("All Total: \(allTotals)")
