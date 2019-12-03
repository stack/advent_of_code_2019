//
//  main.swift
//  Day 03
//
//  Created by Stephen H. Gerstacker on 2019-12-03.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Instruction {
    case up(Int)
    case down(Int)
    case left(Int)
    case right(Int)
}

struct Bounds {
    var minX: Int
    var minY: Int
    var maxX: Int
    var maxY: Int

    var width: Int {
        return maxX - minX
    }

    var height: Int {
        return maxY - minY
    }
}

struct Point: Equatable {
    var x: Int
    var y: Int

    var distanceFromOrigin: Int {
        return abs(x) + abs(y)
    }
}

enum Square {
    case empty
    case origin
    case wire(wireIdx: Int, step: Int, shape: String)
    case intersection(steps: [Int])

    var character: String {
        switch self {
        case .empty: return "."
        case .origin: return "O"
        case .wire(_, _, let shape): return shape
        case .intersection(_): return "X"
        }
    }
}

class Panel {

    let wire1: [Instruction]
    let wire2: [Instruction]
    let shouldPrint: Bool

    init(wire1: [Instruction], wire2: [Instruction], shouldPrint: Bool = false) {
        self.wire1 = wire1
        self.wire2 = wire2
        self.shouldPrint = shouldPrint
    }

    static func parseInstructions(line: String) -> [Instruction] {
        return line.split(separator: ",").map {
            let direction = $0.first!
            let distance = Int($0.dropFirst())!

            switch direction {
            case "U":
                return .up(distance)
            case "D":
                return .down(distance)
            case "L":
                return .left(distance)
            case "R":
                return .right(distance)
            default:
                fatalError("Unhandled direction: \(direction)")
            }
        }
    }

    private func determineBounds(wire: [Instruction]) -> Bounds {
        var bounds = Bounds(minX: 0, minY: 0, maxX: 0, maxY: 0)

        var location = Point(x: 0, y: 0)

        for instruction in wire {
            switch instruction {
            case .up(let d):
                location.y += d
            case .down(let d):
                location.y -= d
            case .left(let d):
                location.x -= d
            case .right(let d):
                location.x += d
            }

            if location.x < bounds.minX {
                bounds.minX = location.x
            }

            if location.x > bounds.maxX {
                bounds.maxX = location.x
            }

            if location.y < bounds.minY {
                bounds.minY = location.y
            }

            if location.y > bounds.maxY {
                bounds.maxY = location.y
            }
        }

        return bounds
    }

    func findIntersection() {
        let bounds1 = determineBounds(wire: wire1)
        let bounds2 = determineBounds(wire: wire2)

        print("Bounds 1: \(bounds1)")
        print("Bounds 2: \(bounds2)")

        let minX = [bounds1.minX, bounds2.minX].min()!
        let minY = [bounds1.minY, bounds2.minY].min()!
        let maxX = [bounds1.maxX, bounds2.maxX].max()!
        let maxY = [bounds1.maxY, bounds2.maxY].max()!

        let width = maxX - minX + 1
        let height = maxY - minY + 1

        var panel: [[Square]] = Array(repeating: Array(repeating: .empty, count: width), count: height)

        let origin: Point = Point(x: -minX, y: -minY)
        print("Origin: \(origin)")

        panel[origin.y][origin.x] = .origin

        printPanel(panel)

        var intersections: [Point] = []

        for (idx, wire) in [wire1, wire2].enumerated() {
            var point = origin
            var totalSteps = 0

            for instruction in wire {
                let wireShape: String
                let xDelta: Int
                let yDelta: Int
                var distance: Int

                switch instruction {
                case .up(let d):
                    wireShape = "|"
                    xDelta = 0
                    yDelta = 1
                    distance = d
                case .down(let d):
                    wireShape = "|"
                    xDelta = 0
                    yDelta = -1
                    distance = d
                case .left(let d):
                    wireShape = "-"
                    xDelta = -1
                    yDelta = 0
                    distance = d
                case .right(let d):
                    wireShape = "-"
                    xDelta = 1
                    yDelta = 0
                    distance = d
                }

                for currentStep in 0 ..< distance {
                    if currentStep == 0 {
                        if case .wire(let wireIdx, let wireStep, _) = panel[point.y][point.x] {
                            panel[point.y][point.x] = .wire(wireIdx: wireIdx, step: wireStep, shape: "+")
                        }
                    }

                    point.x += xDelta
                    point.y += yDelta
                    totalSteps += 1

                    switch panel[point.y][point.x] {
                    case .empty:
                        panel[point.y][point.x] = .wire(wireIdx: idx, step: totalSteps, shape: wireShape)
                    case .origin:
                        fatalError("Crossed origin")
                    case .wire(let wireIdx, let wireStep, _):
                        if wireIdx != idx {
                            panel[point.y][point.x] = .intersection(steps: [wireStep, totalSteps])
                            intersections.append(point)
                        }
                    case .intersection(_):
                        break // NOOP
                    }
                }

                printPanel(panel)
            }
        }

        let adjustedIntersections = intersections.map {
            Point(x: $0.x + minX, y: $0.y + minY)
        }

        if let minimumPoint = adjustedIntersections.min(by: { $0.distanceFromOrigin < $1.distanceFromOrigin }) {
            print("Closest: \(minimumPoint) -> \(minimumPoint.distanceFromOrigin)")
        } else {
            print("No closest found")
        }

        let totalSteps = intersections.map { (point: Point) -> Int in
            if case .intersection(let steps) = panel[point.y][point.x] {
                return steps.reduce(0, +)
            } else {
                fatalError("Intersection was corrupt")
            }
        }

        if let minimumTotalSteps = totalSteps.min() {
            print("Minimum Steps: \(minimumTotalSteps)")
        } else {
            print("No minimum steps")
        }
    }

    func printPanel(_ panel: [[Square]]) {
        guard shouldPrint else {
            return
        }

        for line in panel.reversed() {
            print(line.map { $0.character }.joined(separator: ""))
        }
    }

}

let shouldPrintString = CommandLine.arguments.dropFirst().first
let shouldPrint: Bool

if let value = shouldPrintString {
    shouldPrint = value == "print"
} else {
    shouldPrint = false
}

let wires = lineGenerator(fileHandle: .standardInput).map {
    return Panel.parseInstructions(line: $0)
}

let panel = Panel(wire1: wires[0], wire2: wires[1], shouldPrint: shouldPrint)

panel.findIntersection()
