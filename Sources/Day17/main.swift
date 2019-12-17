//
//  main.swift
//  Day 17
//
//  Created by Stephen H. Gerstacker on 2019-12-17.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Direction {
    case north
    case south
    case east
    case west
}

enum Square {
    case scaffold
    case empty
    case robot
}

let data = Data.input

let program = IntcodeComputer(data: data, inputs: [])

var map: [Point:Square] = [:]
var direction: Direction = .north

var x = 0
var y = 0

var width = 0
var height = 0

while !program.isHalted {
    program.run()

    if program.hasOutput {
        let outputNumber = program.getOutput()

        switch outputNumber {
        case 35: // #
            let point = Point(x: x, y: y)
            map[point] = .scaffold
            x += 1
        case 46: // .
            let point = Point(x: x, y: y)
            map[point] = .empty
            x += 1
        case 10: // \n
            x = 0
            y += 1
        case 60: // <
            let point = Point(x: x, y: y)
            map[point] = .robot
            direction = .west
            x += 1
        case 62: // >
            let point = Point(x: x, y: y)
            map[point] = .robot
            direction = .east
            x += 1
        case 94: // ^
            let point = Point(x: x, y: y)
            map[point] = .robot
            direction = .north
            x += 1
        case 118: // v
            let point = Point(x: x, y: y)
            map[point] = .robot
            direction = .south
            x += 1
        default:
            fatalError("Unhandled output: \(outputNumber)")
        }

        width = max(width, x)
        height = y - 1
    }
}

for y in 0 ..< height {
    var row = ""

    for x in 0 ..< width {
        let point = Point(x: x, y: y)

        switch map[point]! {
        case .empty:
            row += "."
        case .scaffold:
            row += "#"
        case .robot:
            switch direction {
            case .north:
                row += "^"
            case .south:
                row += "v"
            case .east:
                row += ">"
            case .west:
                row += "<"
            }
        }
    }

    print(row)
}
