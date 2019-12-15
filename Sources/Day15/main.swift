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

    static let blockSize = 20

    let computer: IntcodeComputer

    var currentPosition: Point
    var map: [Point:Space]
    var unexplored: [Point]
    var oxygenSensorPosition: Point

    var minX = 0
    var minY = 0
    var maxX = 0
    var maxY = 0

    let animator: Animator?

    var debugPrint = true

    init(program: [Int], animator: Animator? = nil) {
        computer = IntcodeComputer(data: program, inputs: [])

        currentPosition = .zero
        
        map = [
            currentPosition: .empty
        ]

        unexplored = []
        oxygenSensorPosition = .max

        self.animator = animator
    }

    private func debug(_ message: String) {
        guard debugPrint else {
            return
        }

        print(message)
    }

    private func draw() {
        guard let animator = animator else {
            return
        }

        animator.draw { context in
            let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
            let backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

            context.setFillColor(backgroundColor)
            context.fill(backgroundBounds)

            for (point, space) in map {
                let spaceBounds = CGRect(
                    x: (point.x - minX) * Skutter.blockSize,
                    y: (point.y - minY) * Skutter.blockSize,
                    width: Skutter.blockSize,
                    height: Skutter.blockSize
                )

                let spaceColor: CGColor

                switch space {
                case .empty:
                    spaceColor = CGColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0)
                case .oxygen:
                    spaceColor = CGColor(red: 0.39, green: 0.82, blue: 1.00, alpha: 1.0)
                case .wall:
                    spaceColor = CGColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 1.0)
                }

                context.setFillColor(spaceColor)
                context.fill(spaceBounds)
            }

            let skutterBounds = CGRect(
                x: (currentPosition.x - minX) * Skutter.blockSize,
                y: (currentPosition.y - minY) * Skutter.blockSize,
                width: Skutter.blockSize,
                height: Skutter.blockSize)
                .insetBy(dx: CGFloat(Skutter.blockSize / 4), dy: CGFloat(Skutter.blockSize / 4))

            let skutterColor = CGColor(red: 0.75, green: 0.35, blue: 0.95, alpha: 1.0)

            context.setFillColor(skutterColor)
            context.fill(skutterBounds)
        }
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

        draw()

        while !unexplored.isEmpty {
            let exploringPoint = unexplored.removeFirst()
            debug("Next point to explore: \(exploringPoint)")

            // Move to the exploring point from the current point
            var directions = path(to: exploringPoint)
            debug("Movement from \(currentPosition) to \(exploringPoint): \(directions)")

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

                debug("-   Moved \(direction) to \(currentPosition)")

                draw()
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

                debug("Exploring \(direction)")

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
                    debug("-   Hit a wall")
                    shouldReturn = false
                    map[nextPoint] = .wall
                case 1:
                    debug("-   Empty space")
                    shouldReturn = true
                    unexplored.insert(nextPoint, at: 0)
                    map[nextPoint] = .empty
                case 2:
                    debug("-   Oxygen system!")
                    shouldReturn = true
                    oxygenSensorPosition = nextPoint
                    map[nextPoint] = .oxygen
                default:
                    fatalError("Unexpected output movement")
                }

                minX = min(minX, nextPoint.x)
                minY = min(minY, nextPoint.y)
                maxX = max(maxX, nextPoint.x)
                maxY = max(maxY, nextPoint.y)

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

                draw()
            }
        }

        animator?.complete()
    }
}

// MARK: - Part 1

let data = Data.input
let animate = true

let skutter = Skutter(program: data)
skutter.run()

print("Oxygen system at \(skutter.oxygenSensorPosition)")

let path = skutter.path(from: .zero, to: skutter.oxygenSensorPosition)
print("Path: \(path)")
print("Distance: \(path.count)")

// MARK: - Animate Part 1
let animator: Animator?

if animate {
    let width = skutter.maxX - skutter.minX + 1
    let height = skutter.maxY - skutter.minY + 1

    let url = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let saveUrl = url.appendingPathComponent("15.mov")

    animator = Animator(width: width * Skutter.blockSize, height: height * Skutter.blockSize, frameRate: 1.0 / 30.0, url: saveUrl)

    let skutter = Skutter(program: data, animator: animator)
    skutter.debugPrint = false
    skutter.run()
} else {
    animator = nil
}
