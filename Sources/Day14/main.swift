//
//  main.swift
//  Day 14
//
//  Created by Stephen H. Gerstacker on 2019-12-14.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

class Reaction {
    let inputChemicals: [String]
    let inputAmounts: [Int]

    let outputChemical: String
    let outputAmount: Int

    init(inputsChemicals: [String], inputAmounts: [Int], outputChemical: String, outputAmount: Int) {
        self.inputChemicals = inputsChemicals
        self.inputAmounts = inputAmounts
        self.outputChemical = outputChemical
        self.outputAmount = outputAmount
    }
}

class NanoFactory {

    let reactions: [Reaction]

    var inventory: [String:Int] = [:]
    var needs: [(Int,String)] = []
    var neededOre = 0

    var printDebug = true

    var isInventoryEmpty: Bool {
        let inventoryCount = inventory.reduce(0) { $0 + $1.value }
        return inventoryCount == 0
    }

    init(data: String) {
        reactions = data.split(separator: "\n")
            .map {
                let index = $0.range(of: " => ")!

                let left = $0[$0.startIndex ..< index.lowerBound]
                let right = $0[index.upperBound ..< $0.endIndex]

                var inputChemicals: [String] = []
                var inputAmounts: [Int] = []

                for data in left.split(separator: ",") {
                    let parts = data.split(separator: " ")
                    inputAmounts.append(Int(String(parts[0]))!)
                    inputChemicals.append(String(parts[1]))
                }

                let parts = right.split(separator: " ")

                let outputAmount = Int(String(parts[0]))!
                let outputChemical = String(parts[1])

                return Reaction(inputsChemicals: inputChemicals, inputAmounts: inputAmounts, outputChemical: outputChemical, outputAmount: outputAmount)
            }
    }

    private func debug(_ message: String) {
        guard printDebug else {
            return
        }

        print(message)
    }

    func run(target: Int) {
        inventory = [:]
        needs = [(target, "FUEL")]
        neededOre = 0

        while !needs.isEmpty {
            // Get the next need
            let (neededAmount, neededChemical) = needs.removeFirst()
            debug("Need \(neededAmount) of \(neededChemical)")

            // Pull any amount we have from inventory to consider
            let existingAmount = inventory.removeValue(forKey: neededChemical) ?? 0

            // If that's enough, just consume it
            if neededAmount <= existingAmount {
                let remaining = existingAmount - neededAmount
                debug("-   Using inventory, leaving \(remaining)")

                inventory[neededChemical] = remaining

                continue
            }

            // Find the reaction that creates the need
            let reaction = reactions.first { $0.outputChemical == neededChemical }!

            // How many times do we need to run the reaction to have enough for the need?
            var reactionCount = (neededAmount - existingAmount) / reaction.outputAmount

            if (neededAmount - existingAmount) % reaction.outputAmount != 0 {
                reactionCount += 1
            }

            debug("-   Reaction needed \(reactionCount) time(s)")

            // How much remains after it was used
            let generatedAmount = reactionCount * reaction.outputAmount
            let remainingAmount = generatedAmount + existingAmount - neededAmount

            debug("-   Generated \(generatedAmount) \(neededChemical), with \(existingAmount) existing, leaving \(remainingAmount)")

            inventory[neededChemical] = remainingAmount

            // Run the reactions, generating the new needs
            let newNeeds = zip(reaction.inputAmounts, reaction.inputChemicals).map { ($0.0 * reactionCount, $0.1) }

            for newNeed in newNeeds {
                if newNeed.1 == "ORE" {
                    debug("-   \(newNeed.0) ORE added to need list")
                    neededOre += newNeed.0
                } else {
                    debug("-   \(newNeed.0) \(newNeed.1) are also needed")
                    needs.append(newNeed)
                }
            }
        }
    }

}


let data = Data.input

let factory = NanoFactory(data: data)
factory.run(target: 1)


print()
print("=====================================")
print("  Total ORE needed: \(factory.neededOre)")
print("=====================================")
print()

factory.printDebug = false

var currentTarget = 1_000_000_000_000 / factory.neededOre
var increment = 1_000_000_000
var lastSuccess = currentTarget

while true {
    currentTarget = lastSuccess

    while true {
        factory.run(target: currentTarget)

        print("Target \(currentTarget) generates \(factory.neededOre), increment: \(increment)")

        if factory.neededOre >= 1_000_000_000_000 {
            break
        } else {
            lastSuccess = currentTarget
            currentTarget += increment
        }
    }

    if increment == 1 {
        break
    } else {
        increment /= 10
    }
}

print("Creatable fuel: \(lastSuccess)")
