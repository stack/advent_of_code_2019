//
//  main.swift
//  Day 12
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities
import simd


// MARK: - Data

let input = Data.input
let totalSteps = Data.inputSteps
let printSteps = 100


// MARK: - Constants & Globals

struct PlanetVector: Equatable {
    var position: Int
    var velocity: Int
}


// MARK: - Processing Functions

func process(_ data: inout [PlanetVector], history: inout [[PlanetVector]], steps: Int) {
    var currentStep = 0
    let indexPairs = Array(0 ..< data.count).uniquePairs()

    while true {
        for (index1, index2) in indexPairs {
            let velocity: Int

            if data[index1].position < data[index2].position {
                velocity = 1
            } else if data[index1].position > data[index2].position {
                velocity = -1
            } else {
                velocity = 0
            }

            data[index1].velocity += velocity
            data[index2].velocity -= velocity
        }

        for index in 0 ..< data.count {
            data[index].position += data[index].velocity
        }

        history.append(data)

        currentStep += 1

        if steps == 0 {
            if data == history[0] {
                print("Found a match at step \(currentStep)")
                break
            }
        } else {
            if currentStep == steps {
                break
            }
        }
    }
}

// MARK: - Part 1

print("==================")
print("      Part 1      ")
print("==================")
print()

var xs = input.map {
    return PlanetVector(position: Int($0.x), velocity: 0)
}

var ys = input.map {
    return PlanetVector(position: Int($0.y), velocity: 0)
}

var zs = input.map {
    return PlanetVector(position: Int($0.z), velocity: 0)
}

var xHistory = [xs]
var yHistory = [ys]
var zHistory = [zs]

let queue = DispatchQueue(label: "us.gerstacker.workers", attributes: .concurrent)
let queueGroup = DispatchGroup()

queueGroup.enter()
queue.async {
    print("Started processing xs")
    process(&xs, history: &xHistory, steps: totalSteps)

    print("Finished processing xs")
    queueGroup.leave()
}

queueGroup.enter()
queue.async {
    print("Started processing ys")
    process(&ys, history: &yHistory, steps: totalSteps)

    print("Finished processing ys")
    queueGroup.leave()
}

queueGroup.enter()
queue.async {
    print("Started processing zs")
    process(&zs, history: &zHistory, steps: totalSteps)

    print("Finished processing zs")
    queueGroup.leave()
}

print("Waiting for queues to complete")
queueGroup.wait()
print("Queues are complete!")

for idx in stride(from: 0, to: xHistory.count, by: printSteps) {
    print()
    print("After step \(idx)")

    let xs = xHistory[idx]
    let ys = yHistory[idx]
    let zs = zHistory[idx]

    for planetIdx in 0 ..< xs.count {
        let xPos = String(xs[planetIdx].position).leftPad(length: 5)
        let yPos = String(ys[planetIdx].position).leftPad(length: 5)
        let zPos = String(zs[planetIdx].position).leftPad(length: 5)

        let xVel = String(xs[planetIdx].velocity).leftPad(length: 5)
        let yVel = String(ys[planetIdx].velocity).leftPad(length: 5)
        let zVel = String(zs[planetIdx].velocity).leftPad(length: 5)

        print("pos=<x=\(xPos), y=\(yPos), z=\(zPos)>, vel=<x=\(xVel), y=\(yVel), z=\(zVel)>")
    }
}

print()
print("Energy after \(totalSteps) steps:")

var totalEnergy = 0

for idx in 0 ..< input.count {
    let potentials = [xs[idx].position, ys[idx].position, zs[idx].position]
    let totalPotential = potentials.reduce(0) { $0 + abs($1) }

    let potentialStrings = potentials.map { String($0).leftPad(length: 5) }
    let totalPotentialString = String(totalPotential).leftPad(length: 5)

    let velocities = [xs[idx].velocity, ys[idx].velocity, zs[idx].velocity]
    let totalVelocity = velocities.reduce(0) { $0 + abs($1) }

    let velocityStrings = velocities.map { String($0).leftPad(length: 5) }
    let totalVelocityString = String(totalVelocity).leftPad(length: 5)

    let planetEnergy = totalPotential * totalVelocity
    totalEnergy += planetEnergy

    print("pot: \(potentialStrings.joined(separator: " + ")) = \(totalPotentialString);   kin: \(velocityStrings.joined(separator: " + ")) = \(totalVelocityString);   total: \(planetEnergy)")
}

print("Energy Sum: \(totalEnergy)")

// MARK: - Part 2

print("==================")
print("      Part 2      ")
print("==================")
print()

xs = input.map {
    return PlanetVector(position: Int($0.x), velocity: 0)
}

ys = input.map {
    return PlanetVector(position: Int($0.y), velocity: 0)
}

zs = input.map {
    return PlanetVector(position: Int($0.z), velocity: 0)
}

xHistory = [xs]
yHistory = [ys]
zHistory = [zs]

queueGroup.enter()
queue.async {
    print("Started processing xs")
    process(&xs, history: &xHistory, steps: 0)

    print("Finished processing xs")
    queueGroup.leave()
}

queueGroup.enter()
queue.async {
    print("Started processing ys")
    process(&ys, history: &yHistory, steps: 0)

    print("Finished processing ys")
    queueGroup.leave()
}

queueGroup.enter()
queue.async {
    print("Started processing zs")
    process(&zs, history: &zHistory, steps: 0)

    print("Finished processing zs")
    queueGroup.leave()
}

print("Waiting for queues to complete")
queueGroup.wait()
print("Queues are complete!")

print("X repeated after \(xHistory.count - 1) steps")
print("Y repeated after \(yHistory.count - 1) steps")
print("Z repeeated after \(zHistory.count - 1) steps")

let xFactors = (xHistory.count - 1).factors()
let yFactors = (yHistory.count - 1).factors()
var zFactors = (zHistory.count - 1).factors()

var values = [xHistory.count - 1, yHistory.count - 1, zHistory.count - 1]
var currentValue = 1
var currentMultiple = 2

while true {
    let min = values.min()!

    if currentMultiple > min {
        break
    }
    if values.contains(where: { $0 % currentMultiple == 0 }) {
        values = values.map {
            if $0 % currentMultiple == 0 {
                return $0 / currentMultiple
            } else {
                return $0
            }
        }

        currentValue *= currentMultiple
    } else {
        currentMultiple += 1
    }
}

let remaining = values.reduce(1, *)
let finalSteps = remaining * currentValue

print("Steps needed for repeat: \(finalSteps)")
