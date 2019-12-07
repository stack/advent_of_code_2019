//
//  Amp.swift
//  Day 07
//
//  Created by Stephen H. Gerstacker on 2019-12-07.
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

class Amp {

    var data: [Int]
    var head: Int
    var inputs: [Int]
    var lastOutput: Int

    var isHalted = false

    init(data: [Int], inputs: [Int]) {
        self.data = data
        head = 0
        self.inputs = inputs

        lastOutput = 0
    }

    func add(input: Int) {
        inputs.append(input)
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

        data[outputIdx] = inputs.removeFirst()

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
        lastOutput = value

        return head + 2
    }

    func run() {
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
                keepRunning = false
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
                isHalted = true
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
