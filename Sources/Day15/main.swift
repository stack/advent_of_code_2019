//
//  main.swift
//  Day 15
//
//  Created by Stephen H. Gerstacker on 2019-12-15.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Direction: CustomStringConvertible {
    case north
    case south
    case east
    case west

    var description: String {
        switch self {
        case .north:
            return "N"
        case .south:
            return "S"
        case .east:
            return "E"
        case .west:
            return "W"
        }
    }
}

enum Space {
    case wall
    case empty
    case oxygen
}

class Skutter {

    let computer: IntcodeComputer

    var currentPosition: Point
    var map: [Point:Space]
    var unexplored: [Point]
    var oxygenSensorPosition: Point

    init(program: [Int]) {
        computer = IntcodeComputer(data: program, inputs: [])

        currentPosition = .zero
        
        map = [
            currentPosition: .empty
        ]

        unexplored = []
        oxygenSensorPosition = .max
    }

    func path(from fromPoint: Point, to point: Point) -> [Direction] {
        var frontier = PriorityQueue<Point>()
        var cameFrom: [Point:Point] = [:]
        var costSoFar: [Point:Int] = [:]

        frontier.push(fromPoint, priority: 0)
        costSoFar[fromPoint] = 0

        while !frontier.isEmpty {
            guard let current = frontier.pop() else {
                fatalError("Ran out of frontier, somehow")
            }

            if current == point {
                break
            }

            let nextPoints = [
                Point(x: current.x, y: current.y - 1),
                Point(x: current.x, y: current.y + 1),
                Point(x: current.x - 1, y: current.y),
                Point(x: current.x + 1, y: current.y),
            ]

            for nextPoint in nextPoints {
                guard let space = map[nextPoint], space != .wall else {
                    continue
                }

                let newCost = costSoFar[current]! + 1

                if costSoFar[nextPoint] == nil || newCost < costSoFar[nextPoint]! {
                    costSoFar[nextPoint] = newCost
                    frontier.push(nextPoint, priority: newCost)
                    cameFrom[nextPoint] = current
                }
            }
        }

        var current = point
        var path: [Direction] = []

        while current != fromPoint {
            guard let nextPoint = cameFrom[current] else {
                fatalError("Broken path")
            }

            if nextPoint.x < current.x {
                path.append(.east)
            } else if nextPoint.x > current.x {
                path.append(.west)
            } else if nextPoint.y < current.y {
                path.append(.south)
            } else if nextPoint.y > current.y {
                path.append(.north)
            } else {
                fatalError("Invalid path direction")
            }

            current = nextPoint
        }

        return path.reversed()
    }

    func path(to point: Point) -> [Direction] {
        return path(from: currentPosition, to: point)
    }

    func run() {
        unexplored = [currentPosition]

        while !unexplored.isEmpty {
            let exploringPoint = unexplored.removeFirst()
            print("Next point to explore: \(exploringPoint)")

            // Move to the exploring point from the current point
            var directions = path(to: exploringPoint)
            print("Movement from \(currentPosition) to \(exploringPoint): \(directions)")

            while !directions.isEmpty {
                let direction = directions.removeFirst()

                switch direction {
                case .north:
                    computer.add(input: 1)
                case .south:
                    computer.add(input: 2)
                case .east:
                    computer.add(input: 3)
                case .west:
                    computer.add(input: 4)
                }

                computer.run()

                assert(!computer.isHalted)
                assert(computer.hasOutput)

                let output = computer.getOutput()

                assert(output != 0)

                switch direction {
                case .north:
                    currentPosition = Point(x: currentPosition.x, y: currentPosition.y - 1)
                case .south:
                    currentPosition = Point(x: currentPosition.x, y: currentPosition.y + 1)
                case .east:
                    currentPosition = Point(x: currentPosition.x + 1, y: currentPosition.y)
                case .west:
                    currentPosition = Point(x: currentPosition.x - 1, y: currentPosition.y)
                }

                print("-   Moved \(direction) to \(currentPosition)")
            }

            // Try each direction and add empty spaces to the frontier
            directions = [.north, .south, .east, .west]

            while !directions.isEmpty {
                let direction = directions.removeFirst()

                let nextPoint: Point
                switch direction {
                case .north:
                    nextPoint = Point(x: currentPosition.x, y: currentPosition.y - 1)
                case .south:
                    nextPoint = Point(x: currentPosition.x, y: currentPosition.y + 1)
                case .east:
                    nextPoint = Point(x: currentPosition.x + 1, y: currentPosition.y)
                case .west:
                    nextPoint = Point(x: currentPosition.x - 1, y: currentPosition.y)
                }

                if map[nextPoint] != nil {
                    continue
                }

                print("Exploring \(direction)")

                switch direction {
                case .north:
                    computer.add(input: 1)
                case .south:
                    computer.add(input: 2)
                case .east:
                    computer.add(input: 3)
                case .west:
                    computer.add(input: 4)
                }

                computer.run()

                assert(!computer.isHalted)
                assert(computer.hasOutput)

                var output = computer.getOutput()

                var shouldReturn: Bool

                switch output {
                case 0:
                    print("-   Hit a wall")
                    shouldReturn = false
                    map[nextPoint] = .wall
                case 1:
                    print("-   Empty space")
                    shouldReturn = true
                    unexplored.append(nextPoint)
                    map[nextPoint] = .empty
                case 2:
                    print("-   Oxygen system!")
                    shouldReturn = true
                    oxygenSensorPosition = nextPoint
                    map[nextPoint] = .oxygen
                default:
                    fatalError("Unexpected output movement")
                }

                if shouldReturn {
                    switch direction {
                    case .north:
                        computer.add(input: 2)
                    case .south:
                        computer.add(input: 1)
                    case .east:
                        computer.add(input: 4)
                    case .west:
                        computer.add(input: 3)
                    }

                    computer.run()

                    assert(!computer.isHalted)
                    assert(computer.hasOutput)

                    output = computer.getOutput()

                    assert(output != 0)
                }
            }
        }
    }
}

let data = Data.input

let skutter = Skutter(program: data)
skutter.run()

print("Oxygen system at \(skutter.oxygenSensorPosition)")

let path = skutter.path(from: .zero, to: skutter.oxygenSensorPosition)
print("Path: \(path)")
print("Distance: \(path.count)")
