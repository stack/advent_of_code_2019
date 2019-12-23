//
//  main.swift
//  Day 22
//
//  Created by Stephen H. Gerstacker on 2019-12-22.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import BigInt
import Foundation
import Utilities

let totalCards         = Data.inputTotalCards
let cardsToWatch       = Data.inputCardsToWatch
let instructionsString = Data.inputInstructions

extension BigInt {

    func isEven() -> Bool {
        return self % 2 == 0
    }

}

func power(_ x: BigInt, _ y: BigInt, _ m: BigInt) -> BigInt {
    if y == 0 { return 1 }
    var p = power(x, y / 2, m) % m
    p = (p * p) % m
    return y.isEven() ? p : (x * p) % m
}

func primeModInverse(_ a: BigInt, _ m: BigInt) -> BigInt {
    return power(a, m - 2, m)
}

struct Card {
    let value: BigInt
    let position: BigInt
}

class Deck {

    let totalCards: BigInt
    var cards: [Card]

    init(totalCards: BigInt, cardsToWatch: [BigInt]) {
        self.totalCards = totalCards

        cards = cardsToWatch.map { Card(value: $0, position: $0) }
    }

    func perform(_ instruction: Instruction) {
        switch instruction {
        case .newStack:
            dealInToNewStack()
        case .cut(let amount):
            if amount < 0 {
                cutBack(abs(amount))
            } else {
                cutFront(amount)
            }
        case .increment(let amount):
            dealWithIncrement(amount)
        case .decrement(let amount):
            dealWithDecrement(amount)
        }
    }

    func cutBack(_ size: BigInt) {
        cards = cards.map {
            let nextIndex = nextIndexForCutBack($0.position, amount: size)
            return Card(value: $0.value, position: nextIndex)
        }
    }

    func cutFront(_ size: BigInt) {
        cards = cards.map {
            let nextIndex = nextIndexForCutFront($0.position, amount: size)
            return Card(value: $0.value, position: nextIndex)
        }
    }

    func dealInToNewStack() {
        cards = cards.map {
            let nextIndex = nextIndexForNewStack($0.position)
            return Card(value: $0.value, position: nextIndex)
        }
    }

    func dealWithDecrement(_ increment: BigInt) {
        cards = cards.map {
            let nextIndex = nextIndexForDecrement($0.position, amount: increment)
            return Card(value: $0.value, position: nextIndex)
        }
    }

    func dealWithIncrement(_ increment: BigInt) {
        cards = cards.map {
            let nextIndex = nextIndexForIncrement($0.position, amount: increment)
            return Card(value: $0.value, position: nextIndex)
        }
    }

    private func nextIndexForCutBack(_ index: BigInt, amount: BigInt) -> BigInt {
        if index < totalCards - amount {
            return index + amount
        } else {
            return index - totalCards + amount
        }
    }

    private func nextIndexForCutFront(_ index: BigInt, amount: BigInt) -> BigInt {
        if index < amount {
            return index + totalCards - amount
        } else {
            return index - amount
        }
    }

    private func nextIndexForDecrement(_ index: BigInt, amount: BigInt) -> BigInt {
        return primeModInverse(BigInt(amount), totalCards) * index % totalCards
    }

    private func nextIndexForIncrement(_ index: BigInt, amount: BigInt) -> BigInt {
        return (index * amount) % totalCards
    }

    private func nextIndexForNewStack(_ index: BigInt) -> BigInt {
        return totalCards - index - 1
    }

    func printCards() {
        for card in cards.sorted(by: { $0.position < $1.position }) {
            print("[\(card.position)]: \(card.value)")
        }
    }
}

enum Instruction: CustomStringConvertible {
    case newStack
    case cut(BigInt)
    case increment(BigInt)
    case decrement(BigInt)

    var description: String {
        switch self {
        case .newStack:
            return "deal into new stack"
        case .cut(let x):
            return "cut \(x)"
        case .increment(let x):
            return "deal with increment \(x)"
        case .decrement(let x):
            return "deal with decrement \(x)"
        }
    }

    var inverted: Instruction {
        switch self {
        case .newStack:
            return .newStack
        case .cut(let x):
            return .cut(x * -1)
        case .increment(let x):
            return .decrement(x)
        case .decrement(let x):
            return .increment(x)
        }
    }
}

let newStackRegex = try! NSRegularExpression(pattern: "deal into new stack", options: [])
let cutRegex = try! NSRegularExpression(pattern: "cut (-?\\d+)", options: [])
let incrementRegex = try! NSRegularExpression(pattern: "deal with increment (\\d+)", options: [])

let instructions: [Instruction] = instructionsString.split(separator: "\n").map {
    let instruction = String($0)
    let range = NSRange(location: 0, length: $0.count)

    if let _ = newStackRegex.firstMatch(in: instruction, options: [], range: range) {
        return .newStack
    } else if let match = cutRegex.firstMatch(in: instruction, options: [], range: range) {
        let cutAmountRange = Range(match.range(at: 1), in: instruction)!
        let cutAmount = BigInt(BigInt(instruction[cutAmountRange])!)

        return .cut(cutAmount)
    } else if let match = incrementRegex.firstMatch(in: instruction, options: [], range: range) {
        let incrementAmountRange = Range(match.range(at: 1), in: instruction)!
        let incrementAmount = BigInt(BigInt(instruction[incrementAmountRange])!)

        return .increment(incrementAmount)
    } else {
        fatalError("Unhandled instruction: \($0)")
    }
}

// MARK: - Part 1

/*
let deck1 = Deck(totalCards: totalCards, cardsToWatch: cardsToWatch)

print("Part 1:")

for instruction in instructions {
    print()
    print("-   \(instruction)")

    deck1.perform(instruction)

    deck1.printCards()
}

// MARK: - Part 1 Inverse

print()
print("Part 1 Inverted:")

let reversedInstructions = instructions.reversed()
for instruction in reversedInstructions.map({ $0.inverted }) {
    print()
    print("-   \(instruction)")

    deck1.perform(instruction)

    deck1.printCards()
}
 */

// MARK: - Part 2

let D = BigInt(119315717514047) // deck size
let n = BigInt(101741582076661) // number of repititions
var X = BigInt(2020)

let deck2 = Deck(totalCards: D, cardsToWatch: [X])

for instruction in instructions.reversed().map({ $0.inverted }) {
    deck2.perform(instruction)
}

let Y = deck2.cards[0].position

let deck3 = Deck(totalCards: D, cardsToWatch: [Y])

for instruction in instructions.reversed().map({ $0.inverted }) {
    deck2.perform(instruction)
}

let Z = deck3.cards[0].position

let A = (Y - Z) * primeModInverse(X - Y + D, D) % D
let B = (Y - A * X) % D

let answer = (power(A, n, D) * X + (power(A, n, D) - 1) * primeModInverse(A - 1, D) * B) % D
print("Answer: \(answer)")
