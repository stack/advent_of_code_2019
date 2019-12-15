//
//  main.swift
//  Day 13
//
//  Created by Stephen H. Gerstacker on 2019-12-13.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Cocoa
import CoreText
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

    static let blockWidth: Int = 30
    static let blockHeight: Int = 20

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

    let animator: Animator?

    var totalBlockTiles: Int {
        return tiles.filter { $1 == .block }.count
    }

    init(data: [Int], width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height

        lastBallPosition = .min
        lastPaddlePosition = .min
        score = 0

        tiles = [:]

        computer = IntcodeComputer(data: data, inputs: [])

        if width == 0 || height == 0 {
            animator = nil
        } else {
            let url = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let saveUrl = url.appendingPathComponent("13.mov")

            animator = Animator(width: width * Game.blockWidth, height: height * Game.blockHeight, frameRate: 1.0 / 30.0, url: saveUrl)
        }
    }

    func draw() {
        guard let animator = animator else {
            return
        }

        animator.draw { context in
            let unsetColor        = CGColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            let backgroundColor   = CGColor(red: 0.00, green: 0.00, blue: 0.37, alpha: 1.0)
            let wallColor         = CGColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 1.0)
            let ballColor         = CGColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            let paddleTopColor    = CGColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1.0)
            let paddleBottomColor = CGColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
            let paddleStrokeColor = CGColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
            let blockStrokeColor  = CGColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
            let scoreColor        = CGColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)

            let blockColors1 = [
                CGColor(red: 0.40, green: 0.95, blue: 0.01, alpha: 1.0),
                CGColor(red: 0.99, green: 0.32, blue: 0.84, alpha: 1.0),
                CGColor(red: 0.57, green: 0.69, blue: 0.90, alpha: 1.0),
                CGColor(red: 1.00, green: 1.00, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.98, green: 0.00, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.89, green: 0.89, blue: 0.88, alpha: 1.0)
            ]

            let blockColors2 = [
                CGColor(red: 0.26, green: 0.67, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.51, green: 0.17, blue: 0.41, alpha: 1.0),
                CGColor(red: 0.01, green: 0.00, blue: 0.51, alpha: 1.0),
                CGColor(red: 0.78, green: 0.50, blue: 0.13, alpha: 1.0),
                CGColor(red: 0.48, green: 0.00, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.37, green: 0.37, blue: 0.37, alpha: 1.0)
            ]

            let blockColors3 = [
                CGColor(red: 0.37, green: 0.87, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.75, green: 0.25, blue: 0.63, alpha: 1.0),
                CGColor(red: 0.37, green: 0.50, blue: 0.63, alpha: 1.0),
                CGColor(red: 0.88, green: 0.88, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.75, green: 0.00, blue: 0.00, alpha: 1.0),
                CGColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1.0)
            ]

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)

            context.setFillColor(unsetColor)
            context.fill(backgroundBounds)

            for (point, tile) in tiles {
                let tileBounds = CGRect(x: point.x * Game.blockWidth, y: point.y * Game.blockHeight, width: Game.blockWidth, height: Game.blockHeight)

                switch tile {
                case .ball:
                    context.setFillColor(backgroundColor)
                    context.fill(tileBounds)

                    let center = CGPoint(x: tileBounds.midX, y: tileBounds.midY)
                    let radius = min(tileBounds.width, tileBounds.height) / 2.0

                    let ballBounds = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                    context.setFillColor(ballColor)
                    context.fillEllipse(in: ballBounds)
                case .block:
                    let colorIdx = point.y % blockColors1.count
                    let locations: [CGFloat] = [0.0, 1.0]
                    let colors = [blockColors1[colorIdx], blockColors2[colorIdx]]

                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!

                    let startPoint = CGPoint(x: tileBounds.minX, y: tileBounds.minY)
                    let endPoint = CGPoint(x: tileBounds.maxX, y: tileBounds.maxY)

                    context.saveGState()
                    context.clip(to: tileBounds)

                    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

                    context.restoreGState()

                    let inset = min(Game.blockWidth, Game.blockHeight)
                    let insideBounds = tileBounds.insetBy(dx: CGFloat(inset) * 0.2, dy: CGFloat(inset) * 0.2)

                    context.setFillColor(blockColors3[colorIdx])
                    context.fill(insideBounds)

                    context.setStrokeColor(blockStrokeColor)
                    context.stroke(tileBounds)
                case .empty:
                    context.setFillColor(backgroundColor)
                    context.fill(tileBounds)
                case .horizontalPaddle:
                    context.setFillColor(backgroundColor)
                    context.fill(tileBounds)

                    let path = CGPath(roundedRect: tileBounds, cornerWidth: 5.0, cornerHeight: 5.0, transform: nil)

                    let locations: [CGFloat] = [0.0, 1.0]
                    let colors = [paddleTopColor, paddleBottomColor]

                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!

                    let startPoint = CGPoint(x: tileBounds.midX, y: tileBounds.minY)
                    let endPoint = CGPoint(x: tileBounds.midX, y: tileBounds.maxY)

                    context.saveGState()
                    context.addPath(path)
                    context.clip()

                    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

                    context.restoreGState()

                    context.setStrokeColor(paddleStrokeColor)
                    context.addPath(path)
                    context.strokePath()
                case .wall:
                    context.setFillColor(wallColor)
                    context.fill(tileBounds)
                }
            }

            if score > 0 {
                context.saveGState()

                context.textMatrix = CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(context.height)).scaledBy(x: 1, y: -1)

                context.setFillColor(scoreColor)

                let textBounds = CGRect(x: backgroundBounds.minX + 2.0, y: backgroundBounds.minY + CGFloat(Game.blockHeight) / 2.0, width: backgroundBounds.width, height: CGFloat(Game.blockHeight))

                let scoreString = String(score)
                let scoreAttributes = [
                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: CGFloat(Game.blockHeight) * 0.8),
                    NSAttributedString.Key.foregroundColor: NSColor.white
                ]

                let scoreAttributedString = NSAttributedString(string: scoreString, attributes: scoreAttributes)

                let frameSetter = CTFramesetterCreateWithAttributedString(scoreAttributedString)

                let finalPath = CGMutablePath()
                finalPath.addRect(textBounds)

                let frame = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: 0), finalPath, nil)
                CTFrameDraw(frame, context)

                context.restoreGState()
            }
        }
    }

    func run() {
        var outputs: [Int] = []

        draw()

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

                    var skipDraw = false
                    if tile == .empty {
                        if point == lastBallPosition {
                            skipDraw = true
                        }

                        if point == lastPaddlePosition {
                            skipDraw = true
                        }
                    }

                    minX = min(minX, point.x)
                    maxX = max(maxX, point.x)
                    minY = min(minY, point.y)
                    maxY = max(maxY, point.y)

                    if !skipDraw {
                        draw()
                    }
                }

                outputs.removeAll(keepingCapacity: true)
            }
        }

        animator?.complete()
    }
}

// MARK: - Part 1

let data1 = Data.input

let game1 = Game(data: data1)
game1.run()

print("Total block tiles: \(game1.totalBlockTiles)")

let boardWidth = game1.maxX - game1.minX + 1
let boardHeight = game1.maxY - game1.minY + 1

print("Board Size: \(boardWidth) x \(boardHeight)")

// MARK: - Part 2

var data2 = Data.input
data2[0] = 2

let game2 = Game(data: data2, width: boardWidth, height: boardHeight)
game2.run()

print("Total block tiles: \(game2.totalBlockTiles)")
print("Final Score: \(game2.score)")

