//
//  main.swift
//  Day 20
//
//  Created by Stephen H. Gerstacker on 2019-12-20.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let input = Data.sample1

enum Tile {
    case wall
    case empty
    case teleporter(String)
}

let rawMaze: [[String]] = input.split(separator: "\n").map {
    let line = String($0)
    return Array(line).map { String($0) }
}

var maze: [Point:Tile] = [:]
var teleporters: [String:[Point]] = [:]

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
            let label: String

            if ("A" ... "Z").contains(rawMaze[y-1][x]) {
                label = rawMaze[y-2][x] + rawMaze[y-1][x]
            } else if ("A" ... "Z").contains(rawMaze[y+1][x]) {
                label = rawMaze[y+1][x] + rawMaze[y+2][x]
            } else if ("A" ... "Z").contains(rawMaze[y][x-1]) {
                label = rawMaze[y][x-2] + rawMaze[y][x-1]
            } else if ("A" ... "Z").contains(rawMaze[y][x+1]) {
                label = rawMaze[y][x+1] + rawMaze[y][x+2]
            } else {
                label = ""
            }

            if label.isEmpty {
                maze[point] = .empty
            } else {
                maze[point] = .teleporter(label)

                var existing = teleporters[label, default: []]
                existing.append(point)

                teleporters[label] = existing
            }
        default:
            fatalError("Unhandled tile: \(character)")
        }
    }
}

print("Teleporters: \(teleporters)")
