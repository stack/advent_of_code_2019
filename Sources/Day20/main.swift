//
//  main.swift
//  Day 20
//
//  Created by Stephen H. Gerstacker on 2019-12-20.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let input = Data.input
let animate = true

let animator: Animator?

let blockSize = 16

enum Tile: Equatable {
    case wall
    case empty
    case teleporter(String)
}

var maze: [Point:Tile] = [:]
var teleporters: [String:[Point]] = [:]
var teleporterAdjecent: [Point:Point] = [:]
var startPoint: Point = .min
var endPoint: Point = .max

func draw(animator: Animator?, position: Point) {
    animator?.draw { (context) in
        let backgroundColor = CGColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        let wallColor = CGColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 0.6)
        let emptyColor = CGColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.6)
        let positionColor = CGColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
        let teleporterColor = CGColor(red: 0.39, green: 0.82, blue: 1.0, alpha: 1.0)

        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
        context.setFillColor(backgroundColor)
        context.fill(backgroundBounds)

        for (point, tile) in maze {
            let tileBounds = CGRect(x: point.x * blockSize, y: point.y * blockSize, width: blockSize, height: blockSize)

            switch tile {
            case .empty:
                context.setFillColor(emptyColor)
            case .wall:
                context.setFillColor(wallColor)
            case .teleporter(_):
                context.setFillColor(teleporterColor)
            }

            context.fill(tileBounds)
        }

        let positionBounds = CGRect(x: position.x * blockSize, y: position.y * blockSize, width: blockSize, height: blockSize)
        context.setFillColor(positionColor)
        context.fill(positionBounds)
    }
}

let rawMaze: [[String]] = input.split(separator: "\n").map {
    let line = String($0)
    return Array(line).map { String($0) }
}

for (y, line) in input.split(separator: "\n").enumerated() {
    for (x, character) in line.enumerated() {
        let point = Point(x: x, y: y)

        switch character {
        case " ":
            break
        case "A" ... "Z":
            break
        case "#":
            maze[point] = .wall
        case ".":
            maze[point] = .empty

            let label: String
            let teleporterPoint: Point

            if ("A" ... "Z").contains(rawMaze[y-1][x]) {
                label = rawMaze[y-2][x] + rawMaze[y-1][x]
                teleporterPoint = Point(x: x, y: y - 1)
            } else if ("A" ... "Z").contains(rawMaze[y+1][x]) {
                label = rawMaze[y+1][x] + rawMaze[y+2][x]
                teleporterPoint = Point(x: x, y: y + 1)
            } else if ("A" ... "Z").contains(rawMaze[y][x-1]) {
                label = rawMaze[y][x-2] + rawMaze[y][x-1]
                teleporterPoint = Point(x: x - 1, y: y)
            } else if ("A" ... "Z").contains(rawMaze[y][x+1]) {
                label = rawMaze[y][x+1] + rawMaze[y][x+2]
                teleporterPoint = Point(x: x + 1, y: y)
            } else {
                label = ""
                teleporterPoint = .min
            }

            if !label.isEmpty {
                maze[teleporterPoint] = .teleporter(label)

                var existing = teleporters[label, default: []]
                existing.append(teleporterPoint)

                teleporters[label] = existing

                teleporterAdjecent[teleporterPoint] = point
            }
        default:
            fatalError("Unhandled tile: \(character)")
        }
    }
}

print("Teleporters: \(teleporters)")

if animate {
    let url = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let saveUrl = url.appendingPathComponent("20.mov")

    let width = rawMaze.map { $0.count }.max()!
    animator = Animator(width: width * blockSize, height: rawMaze.count * blockSize,  frameRate: 1.0 / 10.0, url: saveUrl)
} else {
    animator = nil
}

startPoint = teleporterAdjecent[teleporters["AA"]!.first!]!
endPoint = teleporterAdjecent[teleporters["ZZ"]!.first!]!

var frontier = PriorityQueue<Point>()
var cameFrom: [Point:Point] = [:]
var costSoFar: [Point:Int] = [:]

frontier.push(startPoint, priority: 0)
costSoFar[startPoint] = 0

while !frontier.isEmpty {
    let current = frontier.pop()!

    if current == endPoint {
        break
    }

    let deltas = [
        Point(x: current.x, y: current.y - 1),
        Point(x: current.x, y: current.y + 1),
        Point(x: current.x - 1, y: current.y),
        Point(x: current.x + 1, y: current.y)
    ]

    let nextPoints: [Point] = deltas.map {
        if case .teleporter(let label) = maze[$0] {
            let positions = teleporters[label]!

            if positions.count == 1 {
                return $0
            } else {
                let otherPosition = positions[0] == $0 ? positions[1] : positions[0]
                return teleporterAdjecent[otherPosition]!
            }
        } else {
            return $0
        }
    }

    for nextPoint in nextPoints {
        guard let tile = maze[nextPoint] else {
            continue
        }

        guard tile != .wall else {
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

var current = endPoint
var path: [Point] = [endPoint]

while current != startPoint {
    guard let nextPoint = cameFrom[current] else {
        fatalError("Broken path")
    }

    path.append(nextPoint)
    current = nextPoint
}

print("Path: \(path)")
print("Distance: \(path.count - 1)")

for point in path.reversed() {
    draw(animator: animator, position: point)
}

animator?.complete()


