//
//  main.swift
//  Day 18
//
//  Created by Stephen H. Gerstacker on 2019-12-18.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Tile {
    case wall
    case empty
}

struct Route {
    let source: Int
    let sourcePoint: Point
    let destination: Int
    let destinationPoint: Point
    let path: [Point]
    let doorsCrossed: UInt32
}

func path(from source: Point, to destination: Point, in map: [[Tile]]) -> [Point]? {
    let width = map[0].count
    let height = map.count

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
            Point(x: current.x + 1, y: current.y),
        ]

        for nextPoint in nextPoints {
            guard nextPoint.x >= 0 && nextPoint.y >= 0 else {
                continue
            }

            guard nextPoint.x < width && nextPoint.y < height else {
                continue
            }

            guard map[nextPoint.y][nextPoint.x] == .empty else {
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
    var path = [destination]

    while current != source {
        guard let previous = cameFrom[current] else {
            return nil
        }

        path.insert(previous, at: 0)
        current = previous
    }

    return Array(path.dropFirst())
}

let data = Data.sample4

let lines = data.split(separator: "\n")
let width = lines[0].count
let height = lines.count

var map: [[Tile]] = [[Tile]](repeating: [Tile](repeating: .empty, count: width), count: height)
var keys: [Int:Point] = [:]
var doors: [Point:Int] = [:]
var startPosition: Point = .min

for (y, line) in lines.enumerated() {
    for (x, character) in line.enumerated() {
        switch character {
        case "#":
            map[y][x] = .wall
        case ".":
            map[y][x] = .empty
        case "@":
            map[y][x] = .empty
            startPosition = Point(x: x, y: y)
        case "a" ... "z":
            map[y][x] = .empty
            let value = Int(String(character).utf8.first! - "a".utf8.first!)
            keys[value] = Point(x: x, y: y)
        case "A" ... "Z":
            map[y][x] = .empty
            let value = Int(character.lowercased().utf8.first! - "a".utf8.first!)
            doors[Point(x: x, y: y)] = value
        default:
            fatalError("Unhandled character: \(character)")
        }
    }
}

print("Map:")
print(data)

print()
print("Keys: \(keys)")
print("Doors: \(doors)")

var routes: [Route] = []

for (key, point) in keys {
    guard let routePath = path(from: startPosition, to: point, in: map) else {
        fatalError("Failed to find a path from @:\(startPosition) to \(key):\(point)")
    }

    let doorsCrossed: [UInt32] = routePath.compactMap {
        if let door = doors[$0] {
            return UInt32(door)
        } else {
            return nil
        }
    }

    let initial: UInt32 = 0
    let doorsCrossedMask = doorsCrossed.reduce(initial) { (sum: UInt32, value: UInt32) -> UInt32 in
        return sum | (1 << value)
    }

    let route = Route(
        source: -1,
        sourcePoint: startPosition,
        destination: key,
        destinationPoint: point,
        path: routePath,
        doorsCrossed: doorsCrossedMask
    )

    routes.append(route)
}

for (sourceKey, sourcePoint) in keys {
    for (destinationKey, destinationPoint) in keys {
        guard sourceKey != destinationKey else {
            continue
        }

        guard let routePath = path(from: sourcePoint, to: destinationPoint, in: map) else {
            fatalError("Failed to find a path from \(sourceKey):\(sourcePoint) to \(destinationKey):\(destinationPoint)")
        }

        let doorsCrossed: [UInt32] = routePath.compactMap {
            if let door = doors[$0] {
                return UInt32(door)
            } else {
                return nil
            }
        }

        let initial: UInt32 = 0
        let doorsCrossedMask = doorsCrossed.reduce(initial) { (sum: UInt32, value: UInt32) -> UInt32 in
            return sum | (1 << value)
        }

        let route = Route(
            source: sourceKey,
            sourcePoint: sourcePoint,
            destination: destinationKey,
            destinationPoint: destinationPoint,
            path: routePath,
            doorsCrossed: doorsCrossedMask
        )

        routes.append(route)
    }
}

routes.sort {
    if $0.source == $1.source {
        return $0.destination < $1.destination
    } else {
        return $0.source < $1.source
    }
}

print()
print("Key Mapping:")

for route in routes {
    print("\(route.source) -> \(route.destination) : \(route.doorsCrossed)")
}

var routeTable: [Int:[Route]] = [:]

for route in routes {
    var existing = routeTable[route.source] ?? []
    existing.append(route)

    existing.sort { $0.path.count < $1.path.count }

    routeTable[route.source] = existing
}

struct State {
    let current: Int
    let visited: UInt32
    let stepsTaken: Int
}

let startingState = State(current: -1, visited: 0, stepsTaken: 0)
var states = [startingState]

func visit(states: [State]) -> [State] {
    if states.count == keys.count + 1 {
        return states
    }

    let currentState = states.last!

    for route in routeTable[currentState.current]! {
        guard (currentState.visited & (1 << route.destination)) == 0 else {
            continue
        }

        guard route.doorsCrossed & currentState.visited == route.doorsCrossed else {
            continue
        }

        var visited = currentState.visited
        visited = visited | (1 << route.destination)

        let stepsTaken = currentState.stepsTaken + route.path.count

        let nextState = State(current: route.destination, visited: visited, stepsTaken: stepsTaken)

        var nextStates = states
        nextStates.append(nextState)

        let result = visit(states: nextStates)

        if result.count == keys.count + 1 {
            return result
        }
    }

    return states
}

let result = visit(states: states)
print(result)

/*
let startingState = State(current: -1, visited: 0, stepsTaken: 0)
var frontier = [startingState]

var foundState: State? = nil
let target = Int(pow(2, Double(keys.count))) - 1

while !frontier.isEmpty {
    var nextFrontier: [State] = []

    while !frontier.isEmpty {
        let currentState = frontier.removeFirst()

        if currentState.visited == target {
            foundState = currentState
            break
        }

        for route in routeTable[currentState.current]! {
            guard (currentState.visited & (1 << route.destination)) == 0 else {
                continue
            }

            guard route.doorsCrossed & currentState.visited == route.doorsCrossed else {
                continue
            }

            var visited = currentState.visited
            visited = visited | (1 << route.destination)

            let stepsTaken = currentState.stepsTaken + route.path.count

            let nextState = State(current: route.destination, visited: visited, stepsTaken: stepsTaken)
            nextFrontier.append(nextState)
        }
    }

    if foundState != nil {
        break
    }

    frontier = nextFrontier.sorted { $0.stepsTaken < $1.stepsTaken }

    print("Frontier size: \(frontier.count)")
}

guard let state = foundState else {
    fatalError("Failed to find a solution")
}

var current: State? = state

print()
print("Found Solution:")

print("Total Steps: \(state.stepsTaken)")
*/
