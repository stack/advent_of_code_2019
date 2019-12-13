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

    var minX: Int = 0
    var maxX: Int = 0
    var minY: Int = 0
    var maxY: Int = 0

    let width: Int
    let height: Int

    let computer: IntcodeComputer

    let animator: Animator?

    var totalBlockTiles: Int {
        return tiles.filter { $1 == .block }.count
    }

    init(data: [Int], width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height

        tiles = [:]

        computer = IntcodeComputer(data: data, inputs: [])

        animator = nil
    }

    func draw() {
        animator?.draw { context in
        }
    }

    func run() {
        var outputs: [Int] = []

        while true {
            computer.run()

            if computer.isHalted {
                break
            }

            outputs.append(computer.lastOutput)

            if outputs.count == 3 {
                let point = Point(x: outputs[0], y: outputs[1])
                let tile = Tile(rawValue: outputs[2])!

                tiles[point] = tile

                print("Added \(tile) @ \(point)")

                minX = min(minX, point.x)
                maxX = max(maxX, point.x)
                minY = min(minY, point.y)
                maxY = max(maxY, point.y)

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

var inputSize = 1
while true {

}

