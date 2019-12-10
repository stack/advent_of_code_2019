//
//  main.swift
//  Day 08
//
//  Created by Stephen H. Gerstacker on 2019-12-08.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

struct Point: Hashable {
    let x: Int
    let y: Int
}

func gcd(_ a: Int, _ b: Int) -> Int {
    if b == 0 {
        return a
    } else {
        return gcd(b, a % b)
    }
}

func printMap(width: Int, height: Int, points: Set<Point>) {
    var map = ""

    for y in 0 ..< height {
        for x in 0 ..< width {
            let point = Point(x: x, y: y)

            if points.contains(point) {
                map += "#"
            } else {
                map += "."
            }
        }

        map += "\n"
    }

    print(map)
}

let mapString = Data.input

// Parse out the points from the map
let rows = mapString.split(separator: "\n")

var asteroids: Set<Point> = []
let width = rows[0].count
let height = rows.count

for (y, row) in rows.enumerated() {
    for (x, space) in row.enumerated() {
        if space == "#" {
            asteroids.insert(Point(x: x, y: y))
        }
    }
}

// Create a map of points to viewable points
var viewable: [Point:[Point]] = asteroids.reduce(into: [:], { $0[$1] = [] })

for sourcePoint in asteroids {
    for destPoint in asteroids {
        if sourcePoint == destPoint {
            continue
        }

        var deltaX = destPoint.x - sourcePoint.x
        var deltaY = destPoint.y - sourcePoint.y

        let divisor = gcd(abs(deltaX), abs(deltaY))

        deltaX /= divisor
        deltaY /= divisor

        var nextPoint = Point(x: sourcePoint.x + deltaX, y: sourcePoint.y + deltaY)
        var isViewable = true

        while nextPoint != destPoint {
            if asteroids.contains(nextPoint) {
                isViewable = false
                break
            }

            nextPoint = Point(x: nextPoint.x + deltaX, y: nextPoint.y + deltaY)
        }

        if isViewable {
            viewable[sourcePoint]?.append(destPoint)
        }
    }
}

// Which has the most?
var bestPoint = Point(x: Int.max, y: Int.max)
var bestCount = Int.min

for (point, viewable) in viewable {
    if viewable.count > bestCount {
        bestPoint = point
        bestCount = viewable.count
    }
}

print("Best: \(bestPoint) = \(bestCount)")
