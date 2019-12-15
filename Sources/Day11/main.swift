//
//  main.swift
//  Day 11
//
//  Created by Stephen H. Gerstacker on 2019-12-11.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

class Robot {

    static let blockSize: Int = 20

    var currentPoint: Point
    var currentDirection: Direction
    var area: [Point:Color]

    var minX: Int = 0
    var maxX: Int = 0
    var minY: Int = 0
    var maxY: Int = 0

    let width: Int
    let height: Int

    let computer: IntcodeComputer

    let animator: Animator?

    var paintedPoints: Int {
        return area.count
    }

    init(data: [Int], startingColor: Color, startingPoint: Point? = nil, width: Int = 0, height: Int = 0) {
        if let point = startingPoint {
            currentPoint = point
        } else {
            currentPoint = .zero
        }

        currentDirection = .up

        area = [
            currentPoint: startingColor
        ]

        self.width = width
        self.height = height

        computer = IntcodeComputer(data: data, inputs: [])

        if startingPoint != nil && width > 0 && height > 0 {
            let url = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let saveUrl = url.appendingPathComponent("11.mov")

            animator = Animator(width: width * Robot.blockSize, height: height * Robot.blockSize, frameRate: 1.0 / 15.0, url: saveUrl)
        } else {
            animator = nil
        }
    }

    func draw() {
        animator?.draw { context in
            let backgroundColor = CGColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
            let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)

            context.setFillColor(backgroundColor)
            context.fill(backgroundBounds)

            let blackColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            let whiteColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

            for (point, color) in area {
                let pointBounds = CGRect(x: point.x * Robot.blockSize, y: point.y * Robot.blockSize, width: Robot.blockSize, height: Robot.blockSize)

                let pointColor: CGColor

                switch color {
                case .black:
                    pointColor = blackColor
                case .white:
                    pointColor = whiteColor
                }

                context.setFillColor(pointColor)
                context.fill(pointBounds)
            }

            let robotBackgroundColor: CGColor

            if let color = area[currentPoint] {
                switch color {
                case .black:
                    robotBackgroundColor = blackColor
                case .white:
                    robotBackgroundColor = whiteColor
                }
            } else {
                robotBackgroundColor = blackColor
            }

            let robotBounds = CGRect(x: currentPoint.x * Robot.blockSize, y: currentPoint.y * Robot.blockSize, width: Robot.blockSize, height: Robot.blockSize)

            context.setFillColor(robotBackgroundColor)
            context.fill(robotBounds)

            let robotColor = CGColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0)

            let point1: CGPoint
            let point2: CGPoint
            let point3: CGPoint

            switch currentDirection {
            case .up:
                point1 = CGPoint(x: robotBounds.midX, y: robotBounds.minY)
                point2 = CGPoint(x: robotBounds.minX, y: robotBounds.maxY)
                point3 = CGPoint(x: robotBounds.maxX, y: robotBounds.maxY)
            case .down:
                point1 = CGPoint(x: robotBounds.midX, y: robotBounds.maxY)
                point2 = CGPoint(x: robotBounds.minX, y: robotBounds.minY)
                point3 = CGPoint(x: robotBounds.maxX, y: robotBounds.minY)
            case .left:
                point1 = CGPoint(x: robotBounds.minX, y: robotBounds.midY)
                point2 = CGPoint(x: robotBounds.maxX, y: robotBounds.maxY)
                point3 = CGPoint(x: robotBounds.maxX, y: robotBounds.minY)
            case .right:
                point1 = CGPoint(x: robotBounds.maxX, y: robotBounds.midY)
                point2 = CGPoint(x: robotBounds.minX, y: robotBounds.minY)
                point3 = CGPoint(x: robotBounds.minX, y: robotBounds.maxY)
            }

            context.move(to: point1)
            context.addLine(to: point2)
            context.addLine(to: point3)

            context.setFillColor(robotColor)
            context.fillPath()
        }
    }

    func run() {
        var input = area[currentPoint]!.rawValue
        computer.add(input: input)

        var outputs: [Int] = []

        draw()

        while true {
            computer.run()

            if computer.isHalted {
                break
            }

            outputs.append(computer.lastOutput)

            if outputs.count == 2 {
                let color = Color(rawValue: outputs[0])
                area[currentPoint] = color

                switch outputs[1] {
                case 0:
                    currentDirection = currentDirection.turnLeft()
                case 1:
                    currentDirection = currentDirection.turnRight()
                default:
                    fatalError("Invalid direction: \(outputs[1])")
                }

                switch currentDirection {
                case .up:
                    currentPoint.y -= 1
                case .down:
                    currentPoint.y += 1
                case .left:
                    currentPoint.x -= 1
                case .right:
                    currentPoint.x += 1
                }

                minX = min(currentPoint.x, minX)
                maxX = max(currentPoint.x, maxX)
                minY = min(currentPoint.y, minY)
                maxY = max(currentPoint.y, maxY)

                input = area[currentPoint]?.rawValue ?? Color.black.rawValue
                computer.add(input: input)

                outputs.removeAll(keepingCapacity: true)

                draw()
            }
        }

        for _ in 0 ..< 10 {
            draw()
        }

        animator?.complete()
    }
}

let data = Data.input
let startingColor: Color = .white

let robot1 = Robot(data: data, startingColor: startingColor)
robot1.run()

print("Painted points: \(robot1.paintedPoints)")
print("Range: \(robot1.minX) - \(robot1.maxX), \(robot1.minY) - \(robot1.maxY)")

let width = robot1.maxX - robot1.minX + 1
let height = robot1.maxY - robot1.minY + 1
let startingPoint = Point(x: robot1.minX * -1, y: robot1.minY * -1)

let robot2 = Robot(data: data, startingColor: startingColor, startingPoint: startingPoint, width: width, height: height)
robot2.run()

print("Painted points: \(robot2.paintedPoints)")
print("Range: \(robot2.minX) - \(robot2.maxX), \(robot2.minY) - \(robot2.maxY)")
