//
//  main.swift
//  Day 05
//
//  Created by Stephen H. Gerstacker on 2019-12-05.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Instruction {
    case add
    case multiply
    case input
    case output
    case jumpIfTrue
    case jumpIfFalse
    case lessThan
    case equals
    case halt
    case invalid
}

enum Parameter {
    case none
    case position(Int)
    case immediate(Int)
}

struct Operation {
    let instruction: Instruction
    let parameters: [Parameter]

    static func parse(program: [Int], head: Int) -> Operation {
        // Read the instruction
        let opcodeString = String(program[head], radix: 10)
        var opcodeDigits = opcodeString.map { Int(String($0), radix: 10)! }

        while opcodeDigits.count < 5 {
            opcodeDigits.insert(0, at: 0)
        }

        let positionMode3 = opcodeDigits[0]
        let positionMode2 = opcodeDigits[1]
        let positionMode1 = opcodeDigits[2]
        let opcode = opcodeDigits[3] * 10 + opcodeDigits[4]

        let operation: Operation

        switch opcode {
        case 1:
            operation = Operation(
                instruction: .add,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                    (positionMode3 == 0) ? .position(program[head + 3]) : .immediate(program[head + 3]),
                ]
            )
        case 2:
            operation = Operation(
                instruction: .multiply,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                    (positionMode3 == 0) ? .position(program[head + 3]) : .immediate(program[head + 3]),
                ]
            )
        case 3:
            operation = Operation(
                instruction: .input,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                ]
            )
        case 4:
            operation = Operation(
                instruction: .output,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                ]
            )
        case 5:
            operation = Operation(
                instruction: .jumpIfTrue,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                ]
            )
        case 6:
            operation = Operation(
                instruction: .jumpIfFalse,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                ]
            )
        case 7:
            operation = Operation(
                instruction: .lessThan,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                    (positionMode3 == 0) ? .position(program[head + 3]) : .immediate(program[head + 3]),
                ]
            )
        case 8:
            operation = Operation(
                instruction: .equals,
                parameters: [
                    (positionMode1 == 0) ? .position(program[head + 1]) : .immediate(program[head + 1]),
                    (positionMode2 == 0) ? .position(program[head + 2]) : .immediate(program[head + 2]),
                    (positionMode3 == 0) ? .position(program[head + 3]) : .immediate(program[head + 3]),
                ]
            )
        case 99:
            operation = Operation(instruction: .halt, parameters: [])
        default:
            operation = Operation(instruction: .invalid, parameters: [])
        }

        return operation
    }

    var length: Int {
        return 1 + parameters.count
    }
}

class Program {

    var initialData: [Int]
    var data: [Int]
    var head: Int
    let input: Int

    init(data: [Int], input: Int) {
        self.initialData = data
        self.data = []
        head = 0
        self.input = input
    }

    private func add(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        data[outputIdx] = value1 + value2

        return head + 4
    }

    private func getDestination(parameter: Parameter) -> Int {
        switch parameter {
        case .position(let idx):
            return idx
        default:
            fatalError("Destination must be a position")
        }
    }

    private func getValue(parameter: Parameter) -> Int {
        switch parameter {
        case .immediate(let value):
            return value
        case .position(let idx):
            return data[idx]
        case .none:
            fatalError("Illegal instruction for get value")
        }
    }

    private func input(parameters: [Parameter]) -> Int {
        let outputIdx = getDestination(parameter: parameters[0])

        data[outputIdx] = input

        return head + 2
    }

    private func jumpIfFalse(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])

        if value1 == 0 {
            return value2
        } else {
            return head + 3
        }
    }

    private func jumpIfTrue(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])

        if value1 != 0 {
            return value2
        } else {
            return head + 3
        }
    }

    private func lessThan(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        data[outputIdx] = (value1 < value2) ? 1 : 0

        return head + 4
    }

    private func equals(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        data[outputIdx] = (value1 == value2) ? 1 : 0

        return head + 4
    }

    private func multiply(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        data[outputIdx] = value1 * value2

        return head + 4
    }

    private func output(parameters: [Parameter]) -> Int {
        let value = getValue(parameter: parameters[0])

        print("Output @ \(head): \(value)")

        return head + 2
    }

    func run() {
        data = initialData
        head = 0

        var keepRunning = true

        while keepRunning {
            // printState()

            let operation = Operation.parse(program: data, head: head)
            let nextHead: Int

            switch operation.instruction {
            case .add:
                nextHead = add(parameters: operation.parameters)
            case .multiply:
                nextHead = multiply(parameters: operation.parameters)
            case .input:
                nextHead = input(parameters: operation.parameters)
            case .output:
                nextHead = output(parameters: operation.parameters)
            case .jumpIfTrue:
                nextHead = jumpIfTrue(parameters: operation.parameters)
            case .jumpIfFalse:
                nextHead = jumpIfFalse(parameters: operation.parameters)
            case .lessThan:
                nextHead = lessThan(parameters: operation.parameters)
            case .equals:
                nextHead = equals(parameters: operation.parameters)
            case .halt:
                keepRunning = false
                nextHead = head
            case .invalid:
                fatalError("Invalid instruction")
            }

            head = nextHead
        }
    }

    private func printState() {
        let output = data.enumerated().map {
            if $0.offset == head {
                return ">>> \($0.element) <<<"
            } else {
                return "\($0.element)"
            }
        }.joined(separator: ",")

        print(output)
    }
}

let programs: [[Int]] = [
    [1002,4,3,4,33], // Test input
    [3,9,8,9,10,9,4,9,99,-1,8], // Is input 8?
    [3,9,7,9,10,9,4,9,99,-1,8], // Is input less than 8?
    [3,3,1108,-1,8,3,4,3,99], // Is input 8?
    [3,3,1107,-1,8,3,4,3,99], // Is input less than 8?
    [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], // Is input non-zero?
    [3,3,1105,-1,9,1101,0,0,12,4,12,99,1], // Is the input non-zero?
    [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], // Input < 8, 999. Input == 8, 1000, Input > 8, 1001
    [3,225,1,225,6,6,1100,1,238,225,104,0,101,71,150,224,101,-123,224,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,2,205,209,224,1001,224,-3403,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1101,55,24,224,1001,224,-79,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1,153,218,224,1001,224,-109,224,4,224,1002,223,8,223,101,5,224,224,1,224,223,223,1002,201,72,224,1001,224,-2088,224,4,224,102,8,223,223,101,3,224,224,1,223,224,223,1102,70,29,225,102,5,214,224,101,-250,224,224,4,224,1002,223,8,223,1001,224,3,224,1,223,224,223,1101,12,52,225,1101,60,71,225,1001,123,41,224,1001,224,-111,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1102,78,66,224,1001,224,-5148,224,4,224,1002,223,8,223,1001,224,2,224,1,223,224,223,1101,29,77,225,1102,41,67,225,1102,83,32,225,1101,93,50,225,1102,53,49,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1107,677,677,224,1002,223,2,223,1005,224,329,101,1,223,223,7,677,677,224,1002,223,2,223,1005,224,344,1001,223,1,223,7,226,677,224,102,2,223,223,1006,224,359,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,374,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,389,1001,223,1,223,1108,226,677,224,1002,223,2,223,1006,224,404,101,1,223,223,1107,677,226,224,102,2,223,223,1006,224,419,101,1,223,223,1007,677,677,224,1002,223,2,223,1005,224,434,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,449,1001,223,1,223,1008,226,677,224,1002,223,2,223,1006,224,464,101,1,223,223,8,677,677,224,1002,223,2,223,1006,224,479,101,1,223,223,108,226,226,224,102,2,223,223,1005,224,494,101,1,223,223,1107,226,677,224,1002,223,2,223,1006,224,509,101,1,223,223,107,226,226,224,1002,223,2,223,1006,224,524,1001,223,1,223,107,677,677,224,1002,223,2,223,1005,224,539,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,108,677,677,224,102,2,223,223,1005,224,569,101,1,223,223,107,677,226,224,102,2,223,223,1005,224,584,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,599,101,1,223,223,1108,677,226,224,1002,223,2,223,1006,224,614,101,1,223,223,8,677,226,224,102,2,223,223,1005,224,629,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,644,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,659,101,1,223,223,108,226,677,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226], // Input part 1
    [3,225,1,225,6,6,1100,1,238,225,104,0,101,71,150,224,101,-123,224,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,2,205,209,224,1001,224,-3403,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1101,55,24,224,1001,224,-79,224,4,224,1002,223,8,223,101,1,224,224,1,223,224,223,1,153,218,224,1001,224,-109,224,4,224,1002,223,8,223,101,5,224,224,1,224,223,223,1002,201,72,224,1001,224,-2088,224,4,224,102,8,223,223,101,3,224,224,1,223,224,223,1102,70,29,225,102,5,214,224,101,-250,224,224,4,224,1002,223,8,223,1001,224,3,224,1,223,224,223,1101,12,52,225,1101,60,71,225,1001,123,41,224,1001,224,-111,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1102,78,66,224,1001,224,-5148,224,4,224,1002,223,8,223,1001,224,2,224,1,223,224,223,1101,29,77,225,1102,41,67,225,1102,83,32,225,1101,93,50,225,1102,53,49,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1107,677,677,224,1002,223,2,223,1005,224,329,101,1,223,223,7,677,677,224,1002,223,2,223,1005,224,344,1001,223,1,223,7,226,677,224,102,2,223,223,1006,224,359,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,374,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,389,1001,223,1,223,1108,226,677,224,1002,223,2,223,1006,224,404,101,1,223,223,1107,677,226,224,102,2,223,223,1006,224,419,101,1,223,223,1007,677,677,224,1002,223,2,223,1005,224,434,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,449,1001,223,1,223,1008,226,677,224,1002,223,2,223,1006,224,464,101,1,223,223,8,677,677,224,1002,223,2,223,1006,224,479,101,1,223,223,108,226,226,224,102,2,223,223,1005,224,494,101,1,223,223,1107,226,677,224,1002,223,2,223,1006,224,509,101,1,223,223,107,226,226,224,1002,223,2,223,1006,224,524,1001,223,1,223,107,677,677,224,1002,223,2,223,1005,224,539,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,108,677,677,224,102,2,223,223,1005,224,569,101,1,223,223,107,677,226,224,102,2,223,223,1005,224,584,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,599,101,1,223,223,1108,677,226,224,1002,223,2,223,1006,224,614,101,1,223,223,8,677,226,224,102,2,223,223,1005,224,629,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,644,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,659,101,1,223,223,108,226,677,224,102,2,223,223,1006,224,674,101,1,223,223,4,223,99,226] // Input part 2
]

let inputs: [Int] = [
    1,
    8,
    8,
    8,
    8,
    10,
    10,
    10,
    1,
    5
]

let programIdx = 9

let programData = programs[programIdx]
let input = inputs[programIdx]

let program = Program(data: programData, input: input)
program.run()
