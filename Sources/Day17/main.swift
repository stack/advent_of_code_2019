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

    var leftDirection: Direction {
        switch self {
        case .north:
            return .west
        case .south:
            return .east
        case .east:
            return .north
        case .west:
            return .south
        }
    }

    var rightDirection: Direction {
        switch self {
        case .north:
            return .east
        case .south:
            return .west
        case .east:
            return .south
        case .west:
            return .north
        }
    }
}

enum Square {
    case scaffold
    case empty
    case robot
}

enum Movement: CustomStringConvertible, Equatable {
    case left(Int)
    case right(Int)

    var description: String {
        switch self {
        case .left(let distance):
            return "L\(distance)"
        case .right(let distance):
            return "R\(distance)"
        }
    }

    var instructions: String {
        switch self {
        case .left(let distance):
            return "L,\(distance)"
        case .right(let distance):
            return "R,\(distance)"
        }
    }

    static func ==(lhs: Movement, rhs: Movement) -> Bool {
        switch (lhs, rhs) {
        case (.left(let l), .left(let r)):
            return l == r
        case (.right(let l), .right(let r)):
            return l == r
        default:
            return false
        }
    }
}

class Map {

    var squares: [Point:Square]
    var robotDirection: Direction
    var robotPosition: Point

    let width: Int
    let height: Int

    init(map: String) {
        squares = [:]
        robotDirection = .north
        robotPosition = .min

        let lines = map.split(separator: "\n")
        var width: Int = .min
        var height: Int = .min

        for (y, line) in lines.enumerated() {
            for (x, data) in line.enumerated() {

                width = max(width, x + 1)
                height = max(height, y + 1)

                let point = Point(x: x, y: y)

                switch data {
                case "#":
                    squares[point] = .scaffold
                case ".":
                    squares[point] = .empty
                case "^":
                    squares[point] = .robot
                    robotPosition = point
                    robotDirection = .north
                case "v":
                    squares[point] = .robot
                    robotPosition = point
                    robotDirection = .south
                case ">":
                    squares[point] = .robot
                    robotPosition = point
                    robotDirection = .east
                case "<":
                    squares[point] = .robot
                    robotPosition = point
                    robotDirection = .west
                default:
                    fatalError("Unhandled character: \(data)")
                }
            }
        }

        self.width = width
        self.height = height
    }

    var intersections: [Point] {
        var points: [Point] = []

        for (point, square) in squares {
            guard square == .scaffold else {
                continue
            }

            let northPoint = Point(x: point.x, y: point.y - 1)
            let southPoint = Point(x: point.x, y: point.y + 1)
            let eastPoint = Point(x: point.x + 1, y: point.y)
            let westPoint = Point(x: point.x - 1, y: point.y)

            let neighbors = [
                squares[northPoint],
                squares[southPoint],
                squares[eastPoint],
                squares[westPoint]
            ].compactMap { $0 }

            if neighbors == [.scaffold, .scaffold, .scaffold, .scaffold] {
                points.append(point)
            }
        }

        return points
    }

    var movements: [Movement] {
        var currentPosition = robotPosition
        var currentDirection = robotDirection

        var movements: [Movement] = []

        while true {
            let leftDistance = distanceTravelable(position: currentPosition, direction: currentDirection.leftDirection)
            let rightDistance = distanceTravelable(position: currentPosition, direction: currentDirection.rightDirection)

            let movement: Movement
            let distance: Int

            if leftDistance == rightDistance {
                break
            } else if leftDistance > rightDistance {
                movement = .left(leftDistance)
                distance = leftDistance
                currentDirection = currentDirection.leftDirection
            } else {
                movement = .right(rightDistance)
                distance = rightDistance
                currentDirection = currentDirection.rightDirection
            }

            movements.append(movement)

            switch currentDirection {
            case .north:
                currentPosition = Point(x: currentPosition.x, y: currentPosition.y - distance)
            case .south:
                currentPosition = Point(x: currentPosition.x, y: currentPosition.y + distance)
            case .east:
                currentPosition = Point(x: currentPosition.x + distance, y: currentPosition.y)
            case .west:
                currentPosition = Point(x: currentPosition.x - distance, y: currentPosition.y)
            }
        }

        return movements
    }

    var totalAlignment: Int {
        return intersections.reduce(0) { $0 + ($1.x * $1.y) }
    }

    private func distanceTravelable(position: Point, direction: Direction) -> Int {
        let deltaX: Int
        let deltaY: Int

        switch direction {
        case .north:
            deltaX = 0
            deltaY = -1
        case .south:
            deltaX = 0
            deltaY = 1
        case .east:
            deltaX = 1
            deltaY = 0
        case .west:
            deltaX = -1
            deltaY = 0
        }

        var distance = 0
        var currentPoint = position

        while true {
            currentPoint = Point(x: currentPoint.x + deltaX, y: currentPoint.y + deltaY)

            guard let square = squares[currentPoint] else {
                return distance
            }

            if square == .empty {
                return distance
            }

            distance += 1
        }
    }

    func calculateMovements() -> [String] {
        let finalMovements = movements

        var aFunction: String = ""
        var bFunction: String = ""
        var cFunction: String = ""
        var mainRoutine: String = ""

        var startIndexes: [(Int,Int,Int)] = []

        for aIndex in 0 ..< finalMovements.count - 2 {
            for bIndex in aIndex + 1 ..< finalMovements.count - 1 {
                for cIndex in bIndex + 1 ..< finalMovements.count {
                    startIndexes.append((aIndex, bIndex, cIndex))
                }
            }
        }

        for (aIndex, bIndex, cIndex) in startIndexes {
            var aSize = 1
            var bSize = 1
            var cSize = 1

            while cIndex + cSize < finalMovements.count {
                let aSlice = finalMovements[aIndex ..< aIndex + aSize]
                let bSlice = finalMovements[bIndex ..< bIndex + bSize]
                let cSlice = finalMovements[cIndex ..< cIndex + cSize]

                aFunction = aSlice.map { $0.instructions }.joined(separator: ",")
                bFunction = bSlice.map { $0.instructions }.joined(separator: ",")
                cFunction = cSlice.map { $0.instructions }.joined(separator: ",")

                var currentMovements = finalMovements
                mainRoutine = ""

                if aFunction.count <= 20 && bFunction.count <= 20 && cFunction.count <= 20 {
                    while !currentMovements.isEmpty && mainRoutine.count <= 20 {
                        if aSlice.count <= currentMovements.count && aSlice == currentMovements[0 ..< aSlice.count] {
                            if !mainRoutine.isEmpty {
                                mainRoutine.append(",")
                            }

                            mainRoutine.append("A")

                            currentMovements.removeFirst(aSlice.count)
                        } else if bSlice.count <= currentMovements.count && bSlice == currentMovements[0 ..< bSlice.count] {
                            if !mainRoutine.isEmpty {
                                mainRoutine.append(",")
                            }

                            mainRoutine.append("B")

                            currentMovements.removeFirst(bSlice.count)
                        } else if cSlice.count <= currentMovements.count && cSlice == currentMovements[0 ..< cSlice.count] {
                            if !mainRoutine.isEmpty {
                                mainRoutine.append(",")
                            }

                            mainRoutine.append("C")

                            currentMovements.removeFirst(cSlice.count)
                        } else {
                            break
                        }
                    }
                }

                if currentMovements.isEmpty {
                    if mainRoutine.count <= 20 {
                        print()
                        print("Match:")
                        print("A: \(aFunction)")
                        print("B: \(bFunction)")
                        print("C: \(cFunction)")
                        print("Main: \(mainRoutine)")

                        return [mainRoutine, aFunction, bFunction, cFunction]
                    }
                }

                aSize += 1

                if aIndex + aSize >= finalMovements.count {
                    aSize = 1
                    bSize += 1
                }

                if bIndex + bSize >= finalMovements.count {
                    aSize = 1
                    bSize = 1
                    cSize += 1
                }
            }
        }

        fatalError("No way to build functions")
    }

    func printMap() {
        var buffer = ""

        buffer += "   "

        for x in 0 ..< width {
            if x != 0 && x % 10 == 0 {
                buffer += "\(x / 10)"
            } else {
                buffer += " "
            }
        }

        buffer += "\n"

        buffer += "   "

        for x in 0 ..< width {
            buffer += "\(x % 10)"
        }

        buffer += "\n"

        for y in 0 ..< height {
            if y != 0 {
                buffer += "\n"
            }

            if y != 0 && y % 10 == 0 {
                buffer += "\(y) "
            } else {
                buffer += " \(y % 10) "
            }

            for x in 0 ..< width {
                let point = Point(x: x, y: y)

                switch squares[point]! {
                case .empty:
                    buffer += "."
                case .scaffold:
                    buffer += "#"
                case .robot:
                    switch robotDirection {
                    case .north:
                        buffer += "^"
                    case .south:
                        buffer += "v"
                    case .east:
                        buffer += ">"
                    case .west:
                        buffer += "<"
                    }
                }
            }
        }

        print(buffer)
    }
}

func generateMap(program: [Int]) -> String {
    var map = ""

    let program = IntcodeComputer(data: program, inputs: [])

    while !program.isHalted {
        program.run()

        if program.hasOutput {
            let outputNumber = program.getOutput()
            let character = String(UnicodeScalar(UInt8(outputNumber)))
            map += character
        }
    }

    return map
}

let shouldGenerateMap = true
let shouldRunMap = true
let continuousFeed = true

let mapString: String

if shouldGenerateMap {
    mapString = generateMap(program: Data.input)
} else {
    mapString = Data.sample2
}

print("Using map:\n\(mapString)")

let map = Map(map: mapString)

print()
print("Parsed map:")
map.printMap()

print()
print("Intersections: \(map.intersections)")
print("Total Alignment: \(map.totalAlignment)")
print("Movements: \(map.movements)")

let movements = map.calculateMovements()

if shouldRunMap {
    var data = Data.input
    data[0] = 2

    var allInputs = movements.joined(separator: "\n")
    allInputs += "\n"
    allInputs += continuousFeed ? "y" : "n"
    allInputs += "\n"

    var inputs = allInputs.utf8.map { Int($0) }

    let computer = IntcodeComputer(data: data, inputs: [])

    while true {
        computer.run()

        if computer.isHalted {
            break
        }

        if computer.needsInput {
            let input = inputs.removeFirst()
            print("Feeding input: \(input)")
            computer.add(input: input)
        }

        if computer.hasOutput {
            let output = computer.getOutput()

            if output > 255 {
                print("Cleaned: \(output)")
            } else if output == 10 {
                print()
            } else {
                print(String(UnicodeScalar(UInt8(output))), terminator: "")
            }
        }
    }
}
