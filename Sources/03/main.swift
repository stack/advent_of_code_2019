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

struct Point {
    var x: Int
    var y: Int

    var distanceFromOrigin: Int {
        return abs(x) + abs(y)
    }
}

class Panel {

    let wire1: [Instruction]
    let wire2: [Instruction]

    init(wire1: [Instruction], wire2: [Instruction]) {
        self.wire1 = wire1
        self.wire2 = wire2
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

    func findIntersection() -> Point? {
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

        var panel: [[String]] = Array(repeating: Array(repeating: ".", count: width), count: height)

        let origin: Point = Point(x: -minX, y: height - minY - 1)
        print("Origin: \(origin)")

        panel[height - minY - 1][-minX] = "O"

        printPanel(panel)

        var intersections: [Point] = []

        for wire in [wire1, wire2] {
            var point = origin

            for instruction in wire {
                let character: String
                let xDelta: Int
                let yDelta: Int
                var distance: Int

                switch instruction {
                case .up(let d):
                    character = "|"
                    xDelta = 0
                    yDelta = -1
                    distance = d
                case .down(let d):
                    character = "|"
                    xDelta = 0
                    yDelta = 1
                    distance = d
                case .left(let d):
                    character = "-"
                    xDelta = -1
                    yDelta = 0
                    distance = d
                case .right(let d):
                    character = "-"
                    xDelta = 1
                    yDelta = 0
                    distance = d
                }

                for _ in 0 ..< distance {
                    point.x += xDelta
                    point.y += yDelta

                    if panel[point.y][point.x] != "." {
                        panel[point.y][point.x] = "X"
                        intersections.append(Point(x: point.x, y: point.y - 1))
                    } else {
                        panel[point.y][point.x] = character
                    }
                }

                panel[point.y][point.x] = "+"

                printPanel(panel)
            }
        }

        return intersections.min { (lhs, rhs) -> Bool in
            lhs.distanceFromOrigin < rhs.distanceFromOrigin
        }
    }

    func printPanel(_ panel: [[String]]) {
        for line in panel {
            print(line.joined(separator: ""))
        }
    }

}

let wires = lineGenerator(fileHandle: .standardInput).map {
    return Panel.parseInstructions(line: $0)
}

let panel = Panel(wire1: wires[0], wire2: wires[1])

if let intersection = panel.findIntersection() {
    print("Closest: \(intersection) -> \(intersection.distanceFromOrigin)")
} else {
    print("No closest found")
}
