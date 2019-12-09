//
//  main.swift
//  Day 02
//
//  Created by Stephen H. Gerstacker on 2019-12-02.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Mode: String {
    case none = "none"
    case first = "first"
    case second = "second"
}

class Program {

    enum Instruction {
        case add(input1: Int, input2: Int, output: Int)
        case multiply(input1: Int, input2: Int, output: Int)
        case halt
        case invalid
    }

    var initialMemory: [Int]
    var memory: [Int]
    var address: Int = 0

    var output: Int {
        return memory[0]
    }

    init(data: [Int]) {
        self.initialMemory = data
        self.memory = data
    }

    func adjust(index: Int, value: Int) {
        memory[index] = value
    }

    func advance(from instruction: Instruction) {
        switch instruction {
        case .add:
            address += 4
        case .multiply:
            address += 4
        case .halt:
            address += 1
        case .invalid:
            break
        }
    }

    func parseNext() -> Instruction {
        switch memory[address] {
        case 1:
            return .add(input1: memory[address + 1], input2: memory[address + 2], output: memory[address + 3])
        case 2:
            return .multiply(input1: memory[address + 1], input2: memory[address + 2], output: memory[address + 3])
        case 99:
            return .halt
        default:
            return .invalid
        }
    }

    func perform(instruction: Instruction) -> Bool {
        switch instruction {
        case .add(let input1, let input2, let output):
            memory[output] = memory[input1] + memory[input2]
            return true
        case .multiply(let input1, let input2, let output):
            memory[output] = memory[input1] * memory[input2]
            return true
        case .halt:
            return false
        case .invalid:
            memory[0] = -1
            return false
        }
    }

    func reset() {
        memory = initialMemory
        address = 0
    }

    func run() {
        while true {
            // printState()

            let instruction = parseNext()
            let keepRunning = perform(instruction: instruction)

            if !keepRunning {
                break
            }

            advance(from: instruction)
        }

        // printState()
        //print("=====")
    }

    func printState() {
        var buffer = "- "

        for (idx, value) in memory.enumerated() {
            if idx != 0 {
                buffer += ","
            }

            if idx == address {
                buffer += ">>>"
            }

            buffer += String(value)

            if idx == address {
                buffer += "<<<"
            }
        }

        print(buffer)
    }
}

let mode: Mode = .second

var data = Data.input
let inputs = Data.inputInputs

switch mode {
case .none:
    let program = Program(data: data)
    program.run()

    print("Output: \(program.output)")
case .first:
    for (idx, input) in inputs.enumerated() {
        data[idx + 1] = input
    }

    let program = Program(data: data)

    program.run()

    print("Output: \(program.output)")
case .second:

    var complete = false

    for noun in 0 ... 99 {
        for verb in 0 ... 99 {
            data[1] = noun
            data[2] = verb

            let program = Program(data: data)
            program.run()

            print("Output: \(program.output)")

            if program.output == 19690720 {
                let result = 100 * noun + verb
                print("Result: \(result)")

                complete = true
                break
            }
        }

        if complete {
            break
        }
    }
}
