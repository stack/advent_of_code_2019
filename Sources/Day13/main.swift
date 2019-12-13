//
//  main.swift
//  Day 13
//
//  Created by Stephen H. Gerstacker on 2019-12-13.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

class Game {

    enum Tile: Int, CustomStringConvertible {
        case empty = 0
        case wall = 1
        case block = 2
        case horizontalPaddle = 3
        case ball = 4

        var description: String {
            switch self {
            case .empty:
                return "Empty"
            case .wall:
                return "Wall"
            case .block:
                return "Block"
            case .horizontalPaddle:
                return "Paddle"
            case .ball:
                return "Ball"
            }
        }
    }

    static let blockSize: Int = 20

    var tiles: [Point:Tile]

    var lastBallPosition: Point
    var lastPaddlePosition: Point
    var score: Int

    var minX: Int = 0
    var maxX: Int = 0
    var minY: Int = 0
    var maxY: Int = 0

    let width: Int
    let height: Int

    let computer: IntcodeComputer

    var totalBlockTiles: Int {
        return tiles.filter { $1 == .block }.count
    }

    init(data: [Int], width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height

        lastBallPosition = Point(x: Int.min, y: Int.min)
        lastPaddlePosition = Point(x: Int.min, y: Int.min)
        score = 0

        tiles = [:]

        computer = IntcodeComputer(data: data, inputs: [])
    }

    func run() {
        var outputs: [Int] = []

        while true {
            computer.run()

            if computer.isHalted {
                break
            }

            if computer.needsInput {
                let xDelta = lastPaddlePosition.x - lastBallPosition.x

                if xDelta > 0 {
                    print("Moving paddle left")
                    computer.add(input: -1)
                } else if xDelta < 0 {
                    print("Moving paddle rigt")
                    computer.add(input: 1)
                } else {
                    print("Paddle stays in place")
                    computer.add(input: 0)
                }
            }

            if computer.hasOutput {
                outputs.append(computer.getOutput())
            }

            if outputs.count == 3 {
                if outputs[0] == -1 && outputs[1] == 0 {
                    score = outputs[2]
                    print("Score: \(score)")
                } else {
                    let point = Point(x: outputs[0], y: outputs[1])
                    let tile = Tile(rawValue: outputs[2])!

                    tiles[point] = tile

                    print("Added \(tile) @ \(point)")

                    if tile == .ball {
                        lastBallPosition = point
                    }

                    if tile == .horizontalPaddle {
                        lastPaddlePosition = point
                    }

                    minX = min(minX, point.x)
                    maxX = max(maxX, point.x)
                    minY = min(minY, point.y)
                    maxY = max(maxY, point.y)
                }

                outputs.removeAll(keepingCapacity: true)
            }
        }
    }
}

let data1 = Data.input

let game1 = Game(data: data1)
game1.run()

print("Total block tiles: \(game1.totalBlockTiles)")

var data2 = Data.input
data2[0] = 2

let game2 = Game(data: data2)
game2.run()

print("Total block tiles: \(game2.totalBlockTiles)")
print("Final Score: \(game2.score)")

