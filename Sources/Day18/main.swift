//
//  main.swift
//  Day 18
//
//  Created by Stephen H. Gerstacker on 2019-12-18.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Square: Equatable {
    case wall
    case empty
    case key(String)
    case door(String)
}

class Maze {

    var map: [Point:Square]
    var doors: [String:Point]
    var keys: [String:Point]

    var heldKeys: [String]

    var currentPosition: Point

    let width: Int
    let height: Int

    init(data: String) {
        map = [:]
        doors = [:]
        keys = [:]

        heldKeys = []

        currentPosition = .min

        var width = 0
        var height = 0

        for (y, line) in data.split(separator: "\n").enumerated() {
            for (x, character) in line.enumerated() {
                let point = Point(x: x, y: y)

                width = max(width, point.x + 1)
                height = max(height, point.y + 1)

                switch character {
                case "#":
                    map[point] = .wall
                case ".":
                    map[point] = .empty
                case "@":
                    map[point] = .empty
                    currentPosition = point
                case "a" ..< "z":
                    let value = String(character)
                    map[point] = .key(value)
                    keys[value] = point
                case "A" ..< "Z":
                    let value = String(character)
                    map[point] = .door(value)
                    doors[value] = point
                default:
                    fatalError("Unhandled character: \(character)")
                }
            }
        }

        self.width = width
        self.height = height
    }

    func path(from: Point, to: Point) -> [Point]? {
        var frontier = PriorityQueue<Point>()
        var cameFrom: [Point:Point] = [:]
        var costSoFar: [Point:Int] = [:]

        frontier.push(from, priority: 0)
        costSoFar[from] = 0

        while !frontier.isEmpty {
            guard let current = frontier.pop() else {
                fatalError("Unexpected empty frontier")
            }

            if current == to {
                break
            }

            let nextPoints = [
                Point(x: current.x, y: current.y - 1),
                Point(x: current.x, y: current.y + 1),
                Point(x: current.x - 1, y: current.y),
                Point(x: current.x + 1, y: current.y)
            ]

            for nextPoint in nextPoints {
                guard map[nextPoint] == .empty || nextPoint == to else {
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

        var current = to
        var path: [Point] = [to]

        while current != from {
            guard let nextPoint = cameFrom[current] else {
                return nil
            }

            path.append(nextPoint)
            current = nextPoint
        }

        return path.reversed()
    }

    func nextTargets() -> [Point] {
        var targets: [Point] = []

        // Try open doors with the keys we have first
        for key in heldKeys {
            if let door = doors[key.uppercased()] {
                targets.append(door)
            }
        }

        // All remaining keys are the next target
        targets.append(contentsOf: keys.values)

        return targets
    }

    func run() {
        var steps = 0

        printMap()
        print("Steps: \(steps)")

        while !doors.isEmpty || !keys.isEmpty {
            // Find the closes target
            let targets = nextTargets()
            let targetPaths = targets
                .compactMap { path(from: currentPosition, to: $0) }
                .sorted { $0.count < $1.count }

            guard let closestTarget = targetPaths.first else {
                fatalError("Could not find a closest target from \(targets.count)")
            }

            // Go to the closest target
            guard let nextPosition = closestTarget.last else {
                fatalError("Closest target is an empty path")
            }

            steps += closestTarget.count

            currentPosition = nextPosition

            // Consume the new position
            switch map[currentPosition]! {
            case .wall:
                fatalError("Moved to wall")
            case .empty:
                fatalError("Moved to an empty space")
            case .key(let c):
                keys.removeValue(forKey: c)
                heldKeys.append(c)
                map[currentPosition] = .empty
            case .door(let c):
                doors.removeValue(forKey: c)
                heldKeys.removeAll { $0 == c.lowercased() }
                map[currentPosition] = .empty
            }

            printMap()
            print("Steps: \(steps)")
        }

        printMap()
        print("Steps: \(steps)")
    }

    func printMap() {
        print()

        var buffer = ""

        for y in 0 ..< height {
            if y != 0 {
                buffer += "\n"
            }

            for x in 0 ..< width {
                let point = Point(x: x, y: y)

                if point == currentPosition {
                    buffer += "@"
                } else {
                    switch map[point]! {
                    case .wall:
                        buffer += "#"
                    case .empty:
                        buffer += "."
                    case .key(let c):
                        buffer += c
                    case .door(let c):
                        buffer += c
                    }
                }
            }
        }

        buffer += "\n"
        buffer += "Keys: "
        buffer += heldKeys.joined(separator: ", ")

        print(buffer)
    }
}

let data = Data.sample3

let maze = Maze(data: data)
maze.run()
