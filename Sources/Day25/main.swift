//
//  main.swift
//  Day 25
//
//  Created by Stephen H. Gerstacker on 2019-12-25.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let data = Data.input
let program = IntcodeComputer(data: data, inputs: [])

let currentRoomRegex = try! NSRegularExpression(pattern: "== (.+) ==", options: [])

var output: String = ""

let badItems: Set<String> = [
    "photons",
    "giant electromagnet",
    "infinite loop",
    "molten lava",
    "escape pod",
]

let goodItems: [String] = [
    "wreath",
    "space heater",
    "coin",
    "pointer",
    "dehydrated water",
    "astrolabe",
    "festive hat",
    "prime number",
]

let commandPath = [
    "west",
    "south",
    "take pointer",
    "south",
    "take prime number",
    "west",
    "take coin",
    "east",
    "north",
    "north",
    "east",
    "south",
    "take festive hat",
    "north",
    "east",
    "south",
    "south",
    "take space heater",
    "south",
    "take astrolabe",
    "north",
    "north",
    "north",
    "north",
    "take wreath",
    "north",
    "west",
    "take dehydrated water",
    "north",
    "east"
]

for command in commandPath {
    let commandString = "\(command)\n"
    let inputs = commandString.utf8.map { Int($0) }

    program.add(inputs: inputs)
}

func runUntilInput(program: IntcodeComputer) -> [String] {
    var outputs: [String] = []
    var output = ""

    while !program.needsInput && !program.isHalted {
        program.run()

        if program.hasOutput {
            let value = program.getOutput()

            if value == 10 {
                outputs.append(output)
                output = ""
            } else {
                output += String(UnicodeScalar(UInt8(value)))
            }
        }
    }

    return outputs
}

func bruteForcePath(program: IntcodeComputer, direction: String, roomName: String) {
    var frontier: [[String]] = goodItems.map { [$0] }

    var currentRoom = roomName
    var commandString = ""
    var inputs: [Int] = []
    var outputs: [String] = []
    var currentInventory: [String] = []

    // Drop everything first
    print("!!! DROPPING EVERYTHING !!!")
    
    for item in goodItems {
        commandString = "drop \(item)\n"
        inputs = commandString.utf8.map { Int($0) }

        program.add(inputs: inputs)

        outputs = runUntilInput(program: program)
        print(outputs.joined(separator: "\n"))
    }

    // Run until we are in a different room
    while currentRoom == roomName {
        print("!!! INVENTORY: \(currentInventory) !!!")

        // Drop all items
        for item in currentInventory {
            print("!!! DROPPING \(item) !!!")

            commandString = "drop \(item)\n"
            inputs = commandString.utf8.map { Int($0) }

            program.add(inputs: inputs)

            outputs = runUntilInput(program: program)
            print(outputs.joined(separator: "\n"))
        }

        let nextItems = frontier.removeFirst()

        // Take the items we need
        for item in nextItems {
            print("!!! TAKING \(item) !!!")

            commandString = "take \(item)\n"
            inputs = commandString.utf8.map { Int($0) }

            program.add(inputs: inputs)

            outputs = runUntilInput(program: program)
            print(outputs.joined(separator: "\n"))
        }

        currentInventory = nextItems

        // Dump inventory for sanity
        commandString = "inv\n"
        inputs = commandString.utf8.map { Int($0) }

        program.add(inputs: inputs)

        outputs = runUntilInput(program: program)
        print(outputs.joined(separator: "\n"))

        // Attempt to go the direction
        commandString = "\(direction)\n"
        inputs = commandString.utf8.map { Int($0) }

        program.add(inputs: inputs)

        outputs = runUntilInput(program: program)
        print(outputs.joined(separator: "\n"))

        // Parse the output for success
        for output in outputs {
            if let match = currentRoomRegex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.count)) {
                let nameRange = Range(match.range(at: 1), in: output)!
                currentRoom = String(output[nameRange])
            }

            if output.contains("heavier") {
                for nextItem in goodItems {
                    if !nextItems.contains(nextItem) {
                        let addition = nextItems + [nextItem]
                        frontier.insert(addition, at: 0)
                    }
                }
            }
        }

    }
}

var currentRoom = ""

let inputLines = lineGenerator(fileHandle: FileHandle.standardInput)

while true {
    program.run()

    if program.isHalted {
        break
    }

    if program.hasOutput {
        let value = program.getOutput()

        if value == 10 {
            if let match = currentRoomRegex.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.count)) {
                let nameRange = Range(match.range(at: 1), in: output)!
                currentRoom = String(output[nameRange])
            }

            print(output)

            output = ""
        } else {
            output += String(UnicodeScalar(UInt8(value)))
        }
    }

    if program.needsInput {
        guard var inputString = inputLines.next() else {
            fatalError("Failed to read input")
        }

        if inputString.first! == "!" {
            bruteForcePath(program: program, direction: String(inputString.dropFirst()), roomName: currentRoom)
        } else {
            inputString += "\n"

            let inputs = inputString.utf8.map { Int($0) }

            for input in inputs {
                program.add(input: input)
            }
        }
    }
}
