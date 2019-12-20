//
//  main.swift
//  Day 20
//
//  Created by Stephen H. Gerstacker on 2019-12-20.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import CoreText
import Foundation
import Utilities

enum Mode {
    case single
    case recursive
}

let input = Data.input
let animate = true
let mode: Mode = .recursive

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
var width: Int = .min
var height: Int = .min

func draw(animator: Animator?, position: Point, level: Int) {
    animator?.draw { (context) in
        let backgroundColor = CGColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        let wallColor = CGColor(red: 0.33, green: 0.33, blue: 0.35, alpha: 0.6)
        let emptyColor = CGColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 0.6)
        let positionColor = CGColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
        let levelColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        let teleporterFont = CTFontCreateWithName("Menlo" as CFString, CGFloat(blockSize) * 0.6, nil)
        let levelFont = CTFontCreateWithName("Menlo" as CFString, CGFloat(blockSize), nil)

        let backgroundBounds = CGRect(x: 0, y: 0, width: context.width, height: context.height)
        context.setFillColor(backgroundColor)
        context.fill(backgroundBounds)

        for (point, tile) in maze {
            let tileBounds = CGRect(x: point.x * blockSize, y: point.y * blockSize, width: blockSize, height: blockSize)

            var label: String? = nil

            switch tile {
            case .empty:
                context.setFillColor(emptyColor)
            case .wall:
                context.setFillColor(wallColor)
            case .teleporter(let l):
                let red = l.hashValue & 0xff
                let green = (l.hashValue >> 8) & 0xff
                let blue = (l.hashValue >> 16) & 0xff

                let color = CGColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
                context.setFillColor(color)

                label = l
            }

            context.fill(tileBounds)

            if let label = label {
                context.saveGState()

                context.textMatrix = CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(context.height)).scaledBy(x: 1, y: -1)

                let range = CFRange(location: 0, length: label.count)

                let attributedLabel = CFAttributedStringCreateMutable(kCFAllocatorDefault, label.count)!
                CFAttributedStringReplaceString(attributedLabel, CFRange(), label as CFString)
                CFAttributedStringSetAttribute(attributedLabel, range, kCTFontAttributeName, teleporterFont)

                let frameSetter = CTFramesetterCreateWithAttributedString(attributedLabel)
                let textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: label.count), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil)

                var textBounds = tileBounds
                textBounds.origin.x += (tileBounds.width - textSize.width) / 2
                textBounds.origin.y += (tileBounds.height - textSize.height) / 2
                textBounds.size.width += (tileBounds.width - textSize.width) / 2
                textBounds.size.height += (tileBounds.height - textSize.height) / 2

                let path = CGMutablePath()
                path.addRect(textBounds)

                let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, label.count), path, nil)

                CTFrameDraw(frame, context)

                context.restoreGState()
            }
        }

        let positionBounds = CGRect(x: position.x * blockSize, y: position.y * blockSize, width: blockSize, height: blockSize)
        context.setFillColor(positionColor)
        context.fill(positionBounds)

        context.saveGState()

        context.textMatrix = CGAffineTransform.identity.translatedBy(x: 0, y: CGFloat(context.height)).scaledBy(x: 1, y: -1)

        let levelLabel = "Level \(level + 1)"
        let range = CFRange(location: 0, length: levelLabel.count)

        let attributedLabel = CFAttributedStringCreateMutable(kCFAllocatorDefault, levelLabel.count)!
        CFAttributedStringReplaceString(attributedLabel, CFRange(), levelLabel as CFString)
        CFAttributedStringSetAttribute(attributedLabel, range, kCTFontAttributeName, levelFont)
        CFAttributedStringSetAttribute(attributedLabel, range, kCTForegroundColorAttributeName, levelColor)

        let frameSetter = CTFramesetterCreateWithAttributedString(attributedLabel)

        let textBounds = CGRect(x: 2, y: 2, width: context.width - 2, height: blockSize * 2)

        let path = CGMutablePath()
        path.addRect(textBounds)

        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, levelLabel.count), path, nil)

        CTFrameDraw(frame, context)

        context.restoreGState()
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

width = rawMaze.map { $0.count }.max()!
height = rawMaze.count

func isExternal(_ point: Point) -> Bool {
    if point.x == 1 || point.x == width - 2 {
        return true
    } else if point.y == 1 || point.y == height - 2 {
        return true
    } else {
        return false
    }
}

if animate {
    let url = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let saveUrl = url.appendingPathComponent("20.mov")

    animator = Animator(width: width * blockSize, height: height * blockSize,  frameRate: 1.0 / 10.0, url: saveUrl)
} else {
    animator = nil
}

struct Node: Equatable, Hashable {
    let point: Point
    let level: Int
}

startPoint = teleporterAdjecent[teleporters["AA"]!.first!]!
endPoint = teleporterAdjecent[teleporters["ZZ"]!.first!]!

let startNode = Node(point: startPoint, level: 0)
let endNode = Node(point: endPoint, level: 0)

var frontier = PriorityQueue<Node>()
var cameFrom: [Node:Node] = [:]
var costSoFar: [Node:Int] = [:]

frontier.push(startNode, priority: 0)
costSoFar[startNode] = 0

while !frontier.isEmpty {
    let current = frontier.pop()!

    if current == endNode {
        break
    }

    let deltas = [
        Point(x: current.point.x, y: current.point.y - 1),
        Point(x: current.point.x, y: current.point.y + 1),
        Point(x: current.point.x - 1, y: current.point.y),
        Point(x: current.point.x + 1, y: current.point.y)
    ]

    let nextNodes: [Node]

    switch mode {
    case .single:
        nextNodes = deltas.map {
            if case .teleporter(let label) = maze[$0] {
                let positions = teleporters[label]!

                if positions.count == 1 {
                    return Node(point: $0, level: current.level)
                } else {
                    let otherPosition = positions[0] == $0 ? positions[1] : positions[0]
                    let adjacentPosition = teleporterAdjecent[otherPosition]!

                    return Node(point: adjacentPosition, level: current.level)
                }
            } else {
                return Node(point: $0, level: current.level)
            }
        }
    case .recursive:
        nextNodes = deltas.compactMap {
            if case .teleporter(let label) = maze[$0] {
                let positions = teleporters[label]!

                if isExternal($0) {
                    if current.level == 0 {
                        return nil
                    } else if label == "AA" || label == "ZZ" {
                        return nil
                    } else {
                        let otherPosition = positions[0] == $0 ? positions[1] : positions[0]
                        let adjacentPosition = teleporterAdjecent[otherPosition]!

                        return Node(point: adjacentPosition, level: current.level - 1)
                    }
                } else {
                    let otherPosition = positions[0] == $0 ? positions[1] : positions[0]
                    let adjacentPosition = teleporterAdjecent[otherPosition]!

                    return Node(point: adjacentPosition, level: current.level + 1)
                }
            } else {
                return Node(point: $0, level: current.level)
            }
        }
    }

    for nextNode in nextNodes {
        guard let tile = maze[nextNode.point] else {
            continue
        }

        guard tile != .wall else {
            continue
        }

        let newCost = costSoFar[current]! + 1

        if costSoFar[nextNode] == nil || newCost < costSoFar[nextNode]! {
            costSoFar[nextNode] = newCost
            frontier.push(nextNode, priority: newCost)
            cameFrom[nextNode] = current
        }
    }
}

var current = endNode
var path: [Node] = [endNode]

while current != startNode {
    guard let nextPoint = cameFrom[current] else {
        fatalError("Broken path")
    }

    path.append(nextPoint)
    current = nextPoint
}

print("Path: \(path)")
print("Distance: \(path.count - 1)")

for node in path.reversed() {
    draw(animator: animator, position: node.point, level: node.level)
}

animator?.complete()


