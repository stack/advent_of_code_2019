//
//  main.swift
//  Day 24
//
//  Created by Stephen H. Gerstacker on 2019-12-24.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data = Data.input
let minutes = Data.inputMinutes

enum Tile: Hashable {
    case empty
    case bug
}

func biodiversity(_ map: [Point:Tile], width: Int, height: Int) -> Int {
    var points = 0

    for y in 0 ..< height {
        for x in 0 ..< width {
            let point = Point(x: x, y: y)
            let tile = map[point]!

            if tile == .bug {
                let position = y * height + x
                points += Int(pow(2.0, Double(position)))
            }
        }
    }

    return points
}

func printMap(_ map: [Point:Tile], width: Int, height: Int) {
    var buffer = ""

    for y in 0 ..< height {
        if y != 0 {
            buffer += "\n"
        }

        for x in 0 ..< width {
            let point = Point(x: x, y: y)
            let tile = map[point]!

            switch tile {
            case .empty:
                buffer += "."
            case .bug:
                buffer += "#"
            }
        }
    }

    print(buffer)
}

var map: [Point:Tile] = [:]
var width = 0
var height = 0

for (y, line) in data.split(separator: "\n").enumerated() {
    for (x, character) in line.enumerated() {
        let point = Point(x: x, y: y)

        let tile: Tile

        switch character {
        case "#":
            tile = .bug
        case ".":
            tile = .empty
        default:
            fatalError("Unhandled input character: \(character)")
        }

        map[point] = tile

        width = max(width, x + 1)
        height = max(height, y + 1)
    }
}

var visited: Set<[Point:Tile]> = []
visited.insert(map)

print("Initial state:")
printMap(map, width: width, height: height)

for minute in 0... {
    var nextMap: [Point:Tile] = [:]

    for (point, tile) in map {
        var adjacentEmpty = 0
        var adjacentBugs = 0

        let adjacentPoints = [
            Point(x: point.x, y: point.y - 1),
            Point(x: point.x, y: point.y + 1),
            Point(x: point.x - 1, y: point.y),
            Point(x: point.x + 1, y: point.y),
        ]

        for adjacentPoint in adjacentPoints {
            let adjacentTile = map[adjacentPoint] ?? .empty

            switch adjacentTile {
            case .bug:
                adjacentBugs += 1
            case .empty:
                adjacentEmpty += 1
            }
        }

        switch tile {
        case .empty:
            if adjacentBugs == 1 || adjacentBugs == 2 {
                nextMap[point] = .bug
            } else {
                nextMap[point] = .empty
            }
        case .bug:
            if adjacentBugs == 1 {
                nextMap[point] = .bug
            } else {
                nextMap[point] = .empty
            }
        }
    }

    map = nextMap

    print()
    print("After \(minute) minute:")
    printMap(map, width: width, height: height)

    if visited.contains(map) {
        break
    }

    visited.insert(map)
}

let points = biodiversity(map, width: width, height: height)
print("Biodiversity: \(points)")


// MARK: - Part 2

class Map {

    let depth: Int
    var tiles: [Point:Tile]

    let width: Int
    let height: Int
    let center: Point

    var hasInnerBugs: Bool {
        for x in 1 ..< width - 1 {
            let point1 = Point(x: x, y: 1)

            if tiles[point1] == .some(.bug) {
                return true
            }

            let point2 = Point(x: x, y: height - 2)

            if tiles[point2] == .some(.bug) {
                return true
            }
        }

        for y in 2 ..< height - 2 {
            let point1 = Point(x: 0, y: y)

            if tiles[point1] == .some(.bug) {
                return true
            }

            let point2 = Point(x: width - 1, y: y)

            if tiles[point2] == .some(.bug) {
                return true
            }
        }

        return false
    }

    var hasOuterBugs: Bool {
        for x in 0 ..< width {
            let point1 = Point(x: x, y: 0)

            if tiles[point1] == .some(.bug) {
                return true
            }

            let point2 = Point(x: x, y: height - 1)

            if tiles[point2] == .some(.bug) {
                return true
            }
        }

        for y in 1 ..< height - 1 {
            let point1 = Point(x: 0, y: y)

            if tiles[point1] == .some(.bug) {
                return true
            }

            let point2 = Point(x: width - 1, y: y)

            if tiles[point2] == .some(.bug) {
                return true
            }
        }

        return false
    }

    var totalBugs: Int {
        var total = 0

        for (point, tile) in tiles {
            if point != center {
                if tile == .bug {
                    total += 1
                }
            }
        }

        return total
    }

    init(depth: Int, width: Int, height: Int) {
        self.depth = depth

        tiles = [:]

        for y in 0 ..< height {
            for x in 0 ..< width {
                let point = Point(x: x, y: y)
                tiles[point] = .empty
            }
        }

        self.width = width
        self.height = height

        center = Point(x: width / 2, y: height / 2)
    }

    init(tiles: [Point:Tile], depth: Int, width: Int, height: Int) {
        self.depth = depth
        self.tiles = tiles

        self.width = width
        self.height = height

        center = Point(x: width / 2, y: height / 2)
    }

    func printMap() {
        var buffer = "Depth: \(depth)"

        for y in 0 ..< height {
            buffer += "\n"

            for x in 0 ..< width {

                if x == center.x && y == center.y {
                    buffer += "?"
                } else {
                    let point = Point(x: x, y: y)
                    let tile = tiles[point]!

                    switch tile {
                    case .empty:
                        buffer += "."
                    case .bug:
                        buffer += "#"
                    }
                }
            }
        }

        print(buffer)
    }
}

class MapSet {

    var maps: [Map]

    var totalBugs: Int {
        return maps.reduce(0) { $0 + $1.totalBugs }
    }

    init(tiles: [Point:Tile], width: Int, height: Int) {
        maps = [Map(tiles: tiles, depth: 0, width: width, height: height)]
    }

    func expand() {
        expandOutward()
        expandInward()
    }

    private func expandInward() {
        let innerMap = maps.last!

        guard innerMap.hasInnerBugs else {
            return
        }

        print("Adding an inner map at depth \(innerMap.depth + 1)")

        let map = Map(depth: innerMap.depth + 1, width: innerMap.width, height: innerMap.height)
        maps.append(map)
    }

    private func expandOutward() {
        let outerMap = maps.first!

        guard outerMap.hasOuterBugs else {
            return
        }

        print("Adding an outer map at depth \(outerMap.depth - 1)")

        let map = Map(depth: outerMap.depth - 1, width: outerMap.width, height: outerMap.height)
        maps.insert(map, at: 0)
    }

    func printAll() {
        for map in maps {
            print()
            map.printMap()
        }
    }

    func step() {
        let nextMaps = maps.map { Map(depth: $0.depth, width: $0.width, height: $0.height) }

        for (mapIdx, map) in maps.enumerated() {
            for (point, tile) in map.tiles {
                var adjacentEmpty = 0
                var adjacentBugs = 0

                let adjacentPoints = [
                    Point(x: point.x, y: point.y - 1),
                    Point(x: point.x, y: point.y + 1),
                    Point(x: point.x - 1, y: point.y),
                    Point(x: point.x + 1, y: point.y),
                ]

                for adjacentPoint in adjacentPoints {
                    let adjacentTiles: [Tile]

                    if adjacentPoint == map.center {
                        if mapIdx < maps.count - 1 {
                            let xDiff = point.x - adjacentPoint.x
                            let yDiff = point.y - adjacentPoint.y

                            let innerPoints: [Point]

                            if xDiff < 0 {
                                innerPoints = (0 ..< map.height).map { Point(x: 0, y: $0) }
                            } else if xDiff > 0 {
                                innerPoints = (0 ..< map.height).map { Point(x: map.width - 1, y: $0) }
                            } else if yDiff < 0 {
                                innerPoints = (0 ..< map.width).map { Point(x: $0, y: 0) }
                            } else if yDiff > 0 {
                                innerPoints = (0 ..< map.width).map { Point(x: $0, y: map.height - 1) }
                            } else {
                                fatalError("Programmer is a dufus")
                            }

                            adjacentTiles = innerPoints.map { maps[mapIdx + 1].tiles[$0]! }
                        } else {
                            adjacentTiles = [.empty]
                        }
                    } else if adjacentPoint.x < 0 {
                        if mapIdx > 0 {
                            let outerMap = maps[mapIdx - 1]
                            let outerPoint = Point(x: outerMap.center.x - 1, y: outerMap.center.y)

                            adjacentTiles = [outerMap.tiles[outerPoint]!]
                        } else {
                            adjacentTiles = [.empty]
                        }
                    } else if adjacentPoint.x >= width {
                        if mapIdx > 0 {
                            let outerMap = maps[mapIdx - 1]
                            let outerPoint = Point(x: outerMap.center.x + 1, y: outerMap.center.y)

                            adjacentTiles = [outerMap.tiles[outerPoint]!]
                        } else {
                            adjacentTiles = [.empty]
                        }
                    } else if adjacentPoint.y < 0 {
                        if mapIdx > 0 {
                            let outerMap = maps[mapIdx - 1]
                            let outerPoint = Point(x: outerMap.center.x, y: outerMap.center.y - 1)

                            adjacentTiles = [outerMap.tiles[outerPoint]!]
                        } else {
                            adjacentTiles = [.empty]
                        }
                    } else if adjacentPoint.y >= height {
                        if mapIdx > 0 {
                            let outerMap = maps[mapIdx - 1]
                            let outerPoint = Point(x: outerMap.center.x, y: outerMap.center.y + 1)

                            adjacentTiles = [outerMap.tiles[outerPoint]!]
                        } else {
                            adjacentTiles = [.empty]
                        }
                    } else {
                        adjacentTiles = [map.tiles[adjacentPoint]!]
                    }

                    for adjacentTile in adjacentTiles {
                        switch adjacentTile {
                        case .bug:
                            adjacentBugs += 1
                        case .empty:
                            adjacentEmpty += 1
                        }
                    }
                }

                switch tile {
                case .empty:
                    if adjacentBugs == 1 || adjacentBugs == 2 {
                        nextMaps[mapIdx].tiles[point] = .bug
                    } else {
                        nextMaps[mapIdx].tiles[point] = .empty
                    }
                case .bug:
                    if adjacentBugs == 1 {
                        nextMaps[mapIdx].tiles[point] = .bug
                    } else {
                        nextMaps[mapIdx].tiles[point] = .empty
                    }
                }
            }
        }

        maps = nextMaps
    }
}

print()
print("--------------")
print()

for (y, line) in data.split(separator: "\n").enumerated() {
    for (x, character) in line.enumerated() {
        let point = Point(x: x, y: y)

        let tile: Tile

        switch character {
        case "#":
            tile = .bug
        case ".":
            tile = .empty
        default:
            fatalError("Unhandled input character: \(character)")
        }

        map[point] = tile

        width = max(width, x + 1)
        height = max(height, y + 1)
    }
}

let mapSet = MapSet(tiles: map, width: width, height: height)

for minute in 0 ..< minutes {
    print()
    print("Before expand step \(minute + 1)")
    mapSet.printAll()

    mapSet.expand()

    print()
    print("Before step \(minute + 1)")
    mapSet.printAll()
    mapSet.step()

    print()
    print("After step \(minute + 1)")
    mapSet.printAll()

    print("Minute \(minute + 1): \(mapSet.totalBugs) bugs")
}

