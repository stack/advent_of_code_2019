//
//  main.swift
//  Day 18
//
//  Created by Stephen H. Gerstacker on 2019-12-18.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

// MARK: - Set up

let data = Data.input2

let timestamp1 = DispatchTime.now()

var maze: [[String]] = []

var starts: [String:Point] = [:]
var keys: [String:Point] = [:]

for (y, line) in data.split(separator: "\n").enumerated() {
    var currentLine: [String] = []

    for (x, tile) in line.enumerated() {
        currentLine.append(String(tile))

        switch tile {
        case "@":
            starts["@\(starts.count)"] = Point(x: x, y: y)
        case "a" ... "z":
            keys[String(tile)] = Point(x: x, y: y)
        default:
            break
        }
    }

    maze.append(currentLine)
}

print(maze)

print("Starts: \(starts)")
print("Keys: \(keys)")

var keyToKey: [String:[(String,[String],Int)]] = [:]

let merged = keys.merging(starts) { (lhs,_) in lhs }

for (key, keyPosition) in merged {
    print("Inspecting \(key), \(keyPosition)")

    var queue: [(Point, [String])] = [ (keyPosition, [])]
    var distance: [Point:Int] = [keyPosition:0]
    var heldKeys: [(String, [String], Int)] = []

    while !queue.isEmpty {
        print("-   Queue: \(queue)")

        let (currentPosition, neededKeys) = queue.removeFirst()

        print("-   From \(currentPosition): \(neededKeys)")

        let deltas = [
            Point(x: 0, y: -1),
            Point(x: 0, y: 1),
            Point(x: -1, y: 0),
            Point(x: 1, y: 0)
        ]

        for delta in deltas {
            let x = currentPosition.x + delta.x
            let y = currentPosition.y + delta.y

            let position = Point(x: x, y: y)
            let tile = maze[y][x]

            guard tile != "#" else {
                continue
            }

            guard distance[position] == nil else {
                continue
            }

            distance[position] = distance[currentPosition]! + 1

            if ("a" ... "z").contains(tile) {
                heldKeys.append((tile, neededKeys, distance[position]!))
            }

            if ("A" ... "Z").contains(tile) {
                queue.append((position, neededKeys + [tile.lowercased()]))
            } else {
                queue.append((position, neededKeys))
            }
        }
    }

    keyToKey[key] = heldKeys
}

print("-   Key 2 Key: \(keyToKey)")

let timestamp2 = DispatchTime.now()

var cache: [Int:Int] = [:]

func reachableKeys(positions: [String], unlocked: [String] = []) -> [(Int, String, Int)] {
    var keys: [(Int, String, Int)] = []

    for (runner, fromKey) in positions.enumerated() {
        for (key, neededKeys, distance) in keyToKey[fromKey]! {
            guard !unlocked.contains(key) else {
                continue
            }

            let neededKeysSet = Set(neededKeys)
            let unlockedSet = Set(unlocked)

            if neededKeysSet.isSubset(of: unlockedSet) {
                keys.append((runner, key, distance))
            }
        }
    }

    return keys
}

func minimumSteps(positions: [String], unlocked: [String] = []) -> Int {
    var hasher = Hasher()
    hasher.combine(positions.sorted())
    hasher.combine(unlocked.sorted())

    let cacheKey = hasher.finalize()

    if let cachedSteps = cache[cacheKey] {
        return cachedSteps
    }

    let keys = reachableKeys(positions: positions, unlocked: unlocked)

    if keys.isEmpty {
        cache[cacheKey] = 0
        return 0
    }

    var steps: [Int] = []

    for (runner, key, distance) in keys {
        var newPositions = positions
        newPositions[runner] = key

        steps.append(distance + minimumSteps(positions: newPositions, unlocked: unlocked + [key]))
    }

    let value = steps.min() ?? 0
    cache[cacheKey] = value

    return value
}

// MARK: - Part 1

cache = [:]
let steps = minimumSteps(positions: Array(starts.keys))

let timestamp3 = DispatchTime.now()

print("Steps: \(steps)")
