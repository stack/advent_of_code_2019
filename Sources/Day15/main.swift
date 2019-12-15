//
//  main.swift
//  Day 15
//
//  Created by Stephen H. Gerstacker on 2019-12-15.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Cocoa
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

let backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
let emptyColor = CGColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0)
let oxygenColor = CGColor(red: 0.39, green: 0.82, blue: 1.00, alpha: 1.0)
let wallColor = CGColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 1.0)
let filledColor = CGColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
let scoreColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let blockSize = 20

class OxygenSimulator {

    let map: [Point:Space]
    var spread: Set<Point>
    var minutes: Int

    var minX: Int = 0
    var minY: Int = 0
    var maxX: Int = 0
    var maxY: Int = 0

    let animator: Animator?

    init(map: [Point:Space], animator: Animator? = nil) {
        self.map = map
        self.animator = animator
        minutes = 0

        spread = []

        for (point, _) in map {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
    }

    func draw() {
        guard let animator = animator else {
            return
        }

        animator.draw { context in
            let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)

            context.setFillColor(backgroundColor)
            context.fill(backgroundBounds)

            for (point, space) in map {
                let spaceBounds = CGRect(
                    x: (point.x - minX) * blockSize,
                    y: (point.y - minY) * blockSize,
                    width: blockSize,
                    height: blockSize
                )

                let spaceColor: CGColor

                if spread.contains(point) {
                    spaceColor = filledColor
                } else {
                    switch space {
                    case .empty:
                        spaceColor = emptyColor
                    case .oxygen:
                        spaceColor = oxygenColor
                    case .wall:
                        spaceColor = wallColor
                    }
                }

                context.setFillColor(spaceColor)
                context.fill(spaceBounds)
            }

            context.saveGState()

            context.textMatrix = CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(context.height)).scaledBy(x: 1, y: -1)

            context.setFillColor(scoreColor)

            let textBounds = CGRect(x: backgroundBounds.minX + 2.0, y: backgroundBounds.minY + CGFloat(blockSize) / 2.0, width: backgroundBounds.width, height: CGFloat(blockSize))

            let minutesString = String(minutes)
            let minutesAttributes = [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: CGFloat(blockSize) * 0.8),
                NSAttributedString.Key.foregroundColor: NSColor.white
            ]

            let minutesAttributedString = NSAttributedString(string: minutesString, attributes: minutesAttributes)

            let frameSetter = CTFramesetterCreateWithAttributedString(minutesAttributedString)

            let finalPath = CGMutablePath()
            finalPath.addRect(textBounds)

            let frame = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: 0), finalPath, nil)
            CTFrameDraw(frame, context)

            context.restoreGState()
        }
    }

    func run() {
        let (oxygenSystemPoint, _) = map.first { (arg0) -> Bool in
            let (_, value) = arg0
            return value == .oxygen
        }!

        var currentPoints = [oxygenSystemPoint]
        spread.insert(oxygenSystemPoint)

        draw()

        while !currentPoints.isEmpty {
            var nextPoints: [Point] = []

            for currentPoint in currentPoints {
                let surroundingPoints = [
                    Point(x: currentPoint.x, y: currentPoint.y - 1),
                    Point(x: currentPoint.x, y: currentPoint.y + 1),
                    Point(x: currentPoint.x - 1, y: currentPoint.y),
                    Point(x: currentPoint.x + 1, y: currentPoint.y),
                ]

                for surroundingPoint in surroundingPoints {
                    if map[surroundingPoint] == .some(.empty) && !spread.contains(surroundingPoint) {
                        nextPoints.append(surroundingPoint)
                        spread.insert(surroundingPoint)
                    }
                }
            }

            if !nextPoints.isEmpty {
                minutes += 1
            }
            
            currentPoints = nextPoints

            draw()
        }
    }
}

class Skutter {

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

            context.setFillColor(backgroundColor)
            context.fill(backgroundBounds)

            for (point, space) in map {
                let spaceBounds = CGRect(
                    x: (point.x - minX) * blockSize,
                    y: (point.y - minY) * blockSize,
                    width: blockSize,
                    height: blockSize
                )

                let spaceColor: CGColor

                switch space {
                case .empty:
                    spaceColor = emptyColor
                case .oxygen:
                    spaceColor = oxygenColor
                case .wall:
                    spaceColor = wallColor
                }

                context.setFillColor(spaceColor)
                context.fill(spaceBounds)
            }

            let skutterBounds = CGRect(
                x: (currentPosition.x - minX) * blockSize,
                y: (currentPosition.y - minY) * blockSize,
                width: blockSize,
                height: blockSize)
                .insetBy(dx: CGFloat(blockSize / 4), dy: CGFloat(blockSize / 4))

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

    animator = Animator(width: width * blockSize, height: height * blockSize, frameRate: 1.0 / 30.0, url: saveUrl)

    let skutter = Skutter(program: data, animator: animator)
    skutter.debugPrint = false
    skutter.run()
} else {
    animator = nil
}

// MARK: - Part 2
let simulator = OxygenSimulator(map: skutter.map, animator: animator)
simulator.run()

print("Minutes to fill: \(simulator.minutes)")

animator?.complete()
