//
//  main.swift
//  Day 08
//
//  Created by Stephen H. Gerstacker on 2019-12-08.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

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
let mapPoint = Data.inputPoint

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

// What's the best point
let laserPoint: Point

if let point = mapPoint {
    print("Using existing point: \(point)")
    laserPoint = point
} else {
    var bestPoint = Point(x: Int.max, y: Int.max)
    var bestCount = Int.min

    for (point, viewable) in viewable {
        if viewable.count > bestCount {
            bestPoint = point
            bestCount = viewable.count
        }
    }

    print("Best: \(bestPoint) = \(bestCount)")

    laserPoint = bestPoint
}

var relativeAngles: [(Point,Float,Int)] = []

for point in asteroids {
    guard point != laserPoint else {
        continue
    }

    let relativePoint = Point(x: point.x - laserPoint.x, y: point.y - laserPoint.y)
    let angle = atan2f(Float(relativePoint.x), Float(relativePoint.y))
    let distance = abs(relativePoint.x) + abs(relativePoint.y)

    relativeAngles.append((point, angle, distance))
}

var remainingAsteroids = relativeAngles.sorted {
    if $0.1 == $1.1 {
        return $0.2 < $1.2
    } else {
        return $0.1 > $1.1
    }
}

var lastAngle: Float = 655321.0
var removedCount = 0

let resetPoint = Point(x: Int.max, y: Int.max)
remainingAsteroids.append((resetPoint, 0.0, 0))

while remainingAsteroids.count != 1 {
    let asteroid = remainingAsteroids.removeFirst()

    if asteroid.0 == resetPoint {
        lastAngle = 655321.0
        remainingAsteroids.append(asteroid)
    } else if asteroid.1 == lastAngle && !remainingAsteroids.isEmpty {
        remainingAsteroids.append(asteroid)
    } else {
        lastAngle = asteroid.1
        removedCount += 1

        print("Asteroid \(removedCount) to be vaporized is at \(asteroid.0)")

        if removedCount == 200 {
            let bet = asteroid.0.x * 100 + asteroid.0.y
            print()
            print("200th! \(bet)")
            print()
        }
    }
}
