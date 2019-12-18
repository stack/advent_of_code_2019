//
//  main.swift
//  Day 18
//
//  Created by Stephen H. Gerstacker on 2019-12-18.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Square: Equatable, Hashable {
    case wall
    case empty
    case key(String)
    case door(String)
}

class PathCache {

    var cache: [Int:[Point]]

    init() {
        cache = [:]
    }

    func get(from source: Point, to destination: Point) -> [Point]? {
        var hasher = Hasher()
        hasher.combine(source)
        hasher.combine(destination)

        let cacheId = hasher.finalize()

        return cache[cacheId]
    }

    func set(from source: Point, to destination: Point, path: [Point]) {
        var hasher = Hasher()
        hasher.combine(source)
        hasher.combine(destination)

        let cacheId = hasher.finalize()

        cache[cacheId] = path
    }
}

struct Maze {
    var map: [Point:Square]
    var keys: [String:Point]

    var currentPosition: Point
    var heldKeys: Set<String>
    var openedDoors: Set<String>

    var movement: [String]

    let width: Int
    let height: Int

    var stepsTaken: Int

    let pathCache: PathCache

    init(data: String) {
        map = [:]
        keys = [:]

        currentPosition = .min
        heldKeys = []
        openedDoors = []

        movement = []

        var width = Int.min
        var height = Int.min

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
                case "a" ... "z":
                    map[point] = .key(String(character))
                    keys[String(character)] = point
                case "A" ... "Z":
                    map[point] = .door(character.lowercased())
                default:
                    fatalError("Unsupported map character: \(character)")
                }
            }
        }

        self.width = width
        self.height = height

        stepsTaken = 0

        pathCache = PathCache()
    }

    func nextPaths() -> [[Point]] {
        let sortedKeys = keys.keys.sorted()

        return sortedKeys.compactMap {
            if heldKeys.contains($0) {
                return nil
            } else {
                return path(from: currentPosition, to: keys[$0]!)
            }
        }
    }

    func path(from source: Point, to destination: Point) -> [Point]? {
        if let cachedPath = pathCache.get(from: source, to: destination) {
            return cachedPath
        }

        var frontier = PriorityQueue<Point>()
        var cameFrom: [Point:Point] = [:]
        var costSoFar: [Point:Int] = [:]

        frontier.push(source, priority: 0)
        costSoFar[source] = 0

        while !frontier.isEmpty {
            let current = frontier.pop()!

            if current == destination {
                break
            }

            let nextPoints = [
                Point(x: current.x, y: current.y - 1),
                Point(x: current.x, y: current.y + 1),
                Point(x: current.x - 1, y: current.y),
                Point(x: current.x + 1, y: current.y)
            ]

            for nextPoint in nextPoints {
                guard let square = map[nextPoint] else {
                    continue
                }

                guard square != .wall else {
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

        var current = destination
        var path: [Point] = [current]

        while current != source {
            guard let nextPoint = cameFrom[current] else {
                return nil
            }

            path.append(nextPoint)
            current = nextPoint
        }

        let finalPath = Array(path.dropLast().reversed())

        pathCache.set(from: source, to: destination, path: finalPath)

        return finalPath
    }

    mutating func walk(on path: [Point]) -> Bool {
        var remainingPath = path

        var lastKeyVisit = ""

        while !remainingPath.isEmpty {
            let nextPoint = remainingPath.removeFirst()

            switch map[nextPoint]! {
            case .wall:
                fatalError("Walked in to a wall")
            case .empty:
                stepsTaken += 1
            case .door(let c):
                if heldKeys.contains(c) {
                    openedDoors.insert(c)
                    stepsTaken += 1
                } else {
                    return false
                }
            case .key(let c):
                heldKeys.insert(c)
                stepsTaken += 1
                lastKeyVisit = c
            }

            currentPosition = nextPoint
        }

        movement.append(lastKeyVisit)

        return true
    }

    func printMap() {
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
                        buffer += heldKeys.contains(c) ? "." : c
                    case .door(let c):
                        buffer += openedDoors.contains(c) ? "." : c.uppercased()
                    }
                }
            }
        }

        buffer += "\nKeys: \(Array(heldKeys))"
        buffer += "\nSteps: \(stepsTaken)"
        buffer += "\nMovement: \(movement)"

        print(buffer)
    }
}

extension Maze: Equatable {
    static func ==(lhs: Maze, rhs: Maze) -> Bool {
        return lhs.map == rhs.map && lhs.currentPosition == rhs.currentPosition && lhs.heldKeys == rhs.heldKeys && lhs.openedDoors == rhs.openedDoors && lhs.stepsTaken == rhs.stepsTaken
    }
}

extension Maze: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(map)
        hasher.combine(currentPosition)
        hasher.combine(heldKeys)
        hasher.combine(openedDoors)
        hasher.combine(stepsTaken)
    }
}

let input = Data.sample4
let maze = Maze(data: input)

/*
var frontier = [maze]
var solvedMaze: Maze? = nil

while !frontier.isEmpty {
    var nextFrontier: [Maze] = []

    for current in frontier {
        print()
        current.printMap()

        if current.heldKeys.count == current.keys.count {
            solvedMaze = current
            break
        }

        for path in current.nextPaths() {
            var nextMaze = current

            guard nextMaze.walk(on: path) else {
                continue
            }

            nextFrontier.append(nextMaze)
        }
    }

    frontier = nextFrontier.sorted { $0.stepsTaken < $1.stepsTaken }
}

guard let finalMaze = solvedMaze else {
    fatalError("Failed to find a solved maze")
}

print()
print("Final map")
finalMaze.printMap()

print("Steps taken: \(finalMaze.stepsTaken)")
 */

var frontier = PriorityQueue<Maze>()
var cameFrom: [Maze:Maze] = [:]
var costSoFar: [Maze:Int] = [:]

frontier.push(maze, priority: 0)
costSoFar[maze] = 0

var solvedMaze: Maze? = nil

while !frontier.isEmpty {
    let current = frontier.pop()!

    print()
    current.printMap()

    if current.heldKeys.count == current.keys.count {
        solvedMaze = current
        break
    }

    for path in current.nextPaths() {
        var nextMaze = current

        guard nextMaze.walk(on: path) else {
            continue
        }

        let newCost = nextMaze.stepsTaken

        if costSoFar[nextMaze] == nil || newCost < costSoFar[nextMaze]! {
            costSoFar[nextMaze] = newCost
            frontier.push(nextMaze, priority: newCost)
            cameFrom[nextMaze] = current
        }
    }
}

guard let finalMaze = solvedMaze else {
    fatalError("Failed to find a solved maze")
}

print("Steps taken: \(finalMaze.stepsTaken)")
