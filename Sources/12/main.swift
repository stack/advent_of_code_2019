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

struct Planet {
    var position: SIMD3<Int32>
    var velocity: SIMD3<Int32>

    var kineticEnergy: Int32 {
        return abs(velocity.x) + abs(velocity.y) + abs(velocity.z)
    }

    var potentialEnergy: Int32 {
        return abs(position.x) + abs(position.y) + abs(position.z)
    }

    var totalEnergy: Int32 {
         return kineticEnergy * potentialEnergy
    }
}

func printPlanets(_ planets: [Planet]) {
    let maxPosLength = planets.reduce(0) { return [$0, String($1.position.x).count, String($1.position.y).count, String($1.position.z).count].max()! }
    let maxVelLength = planets.reduce(0) { return [$0, String($1.velocity.x).count, String($1.velocity.y).count, String($1.velocity.z).count].max()! }

    for planet in planets {
        let posX = String(planet.position.x).leftPad(length: maxPosLength + 1)
        let posY = String(planet.position.y).leftPad(length: maxPosLength + 1)
        let posZ = String(planet.position.z).leftPad(length: maxPosLength + 1)

        let velX = String(planet.velocity.x).leftPad(length: maxVelLength + 1)
        let velY = String(planet.velocity.y).leftPad(length: maxVelLength + 1)
        let velZ = String(planet.velocity.z).leftPad(length: maxVelLength + 1)

        print("pos=<x=\(posX), y=\(posY), z=\(posZ)>, vel=<x=\(velX), y=\(velY), z=\(velZ)>")
    }
}

let input = Data.input
let totalSteps = Data.inputSteps
let printSteps = 10

var planets = input.map {
    return Planet(position: $0, velocity: SIMD3<Int32>.zero)
}

print("After 0 steps:")
printPlanets(planets)

let indexPairs = Array(0 ..< planets.count).uniquePairs()

for step in 0 ..< totalSteps {
    for (index1, index2) in indexPairs {
        let diff1 = planets[index2].position &- planets[index1].position
        let diff2 = planets[index1].position &- planets[index2].position

        let lowerBound = SIMD3<Int32>(repeating: -1)
        let upperBound = SIMD3<Int32>(repeating: 1)

        let velocityDelta1 = diff1.clamped(lowerBound: lowerBound, upperBound: upperBound)
        let velocityDelta2 = diff2.clamped(lowerBound: lowerBound, upperBound: upperBound)

        planets[index1].velocity &+= velocityDelta1
        planets[index2].velocity &+= velocityDelta2
    }

    for index in 0 ..< planets.count {
        planets[index].position &+= planets[index].velocity
    }

    if (step + 1) % printSteps == 0 {
        print()
        print("After \(step + 1) steps:")
        printPlanets(planets)
    }
}

print()
print("Energy after \(totalSteps) steps")
for planet in planets {
    print("pot: \(planet.potentialEnergy); kin: \(planet.kineticEnergy); tot: \(planet.totalEnergy)")
}

let totalEnergy = planets.reduce(0) { $0 + $1.totalEnergy }
print("Total: \(totalEnergy)")
