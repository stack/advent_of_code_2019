//
//  main.swift
//  Day 19
//
//  Created by Stephen H. Gerstacker on 2019-12-19.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let program = Data.input

// MARK: - Part 1

var affectedPoints: Set<Point> = []

for y in 0 ..< 50 {
    for x in 0 ..< 50 {
        let computer = IntcodeComputer(data: program, inputs: [x, y])
        computer.run()

        assert(computer.hasOutput)
        let output = computer.getOutput()

        print(output == 1 ? "#" : ".", terminator: "")

        if output == 1{
            affectedPoints.insert(Point(x: x, y: y))
        }

        computer.run()
        assert(computer.isHalted)
    }

    print()
}

print("Affected points: \(affectedPoints.count)")

// MARK: - Part 2

// Find the point that is the furthest down, and furthest right with a gap
var lastRowEnd: Point = .min

for y in (0 ..< 49).reversed() {
    let edge = Point(x: 49, y: y)
    let target = Point(x: 48, y: y)

    if affectedPoints.contains(target) && !affectedPoints.contains(edge) {
        lastRowEnd = target
        break
    }
}

guard lastRowEnd != .min else {
    fatalError("Could not find right edge in initial data")
}

// Find the left most point along this last row
var lastRowStart: Point = .min

for x in (0 ..< lastRowEnd.x - 1).reversed() {
    let target = Point(x: x, y: lastRowEnd.y)

    if !affectedPoints.contains(target) {
        lastRowStart = Point(x: x + 1, y: lastRowEnd.y)
        break
    }
}

guard lastRowStart != .min else {
    fatalError("Could not find left edge in initial data")
}

print("Start line: \(lastRowStart) - \(lastRowEnd)")

var minX = lastRowStart.x

var currentX = minX
var currentY = lastRowEnd.y + 1

var hasRowOutput = false
var rowStartedX = 0

while true {
    // print("Inspecting \(currentX), \(currentY)")

    let computer = IntcodeComputer(data: program, inputs: [currentX, currentY])
    computer.run()

    let output = computer.getOutput()

    if !hasRowOutput {
        if output == 0 {
            currentX += 1
        } else {
            minX = currentX
            rowStartedX = currentX
            hasRowOutput = true
            affectedPoints.insert(Point(x: currentX, y: currentY))
            currentX += 1
        }
    } else {
        let rowLength = currentX - rowStartedX + 1

        if output == 0 {
            print("Row \(currentY) starts at \(rowStartedX) and is \(rowLength - 1) long")

            currentX = minX
            currentY += 1
            hasRowOutput = false
        } else {
            affectedPoints.insert(Point(x: currentX, y: currentY))


            if rowLength >= 100 {
                var found = true

                for shipY in (currentY - 99 ... currentY) {
                    for shipX in (currentX - 99 ... currentX) {
                        let point = Point(x: shipX, y: shipY)

                        if !affectedPoints.contains(point) {
                            found = false
                            break
                        }
                    }

                    if !found {
                        break
                    }
                }

                if found {
                    let originX = currentX - 99
                    let originY = currentY - 99

                    print("Found space at \(originX), \(originY)")
                    print("Answer: \(originX * 10000 + originY)")
                    break
                }
            }

            currentX += 1
        }
    }
}
