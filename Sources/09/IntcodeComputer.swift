//
//  IntcodeComputer.swift
//  Day 09
//
//  Created by Stephen H. Gerstacker on 2019-12-09.
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
    case adjustRelativeBase
    case halt
    case invalid
}

enum Parameter {
    case none
    case position(Int)
    case immediate(Int)
    case relative(Int)

    static func parse(mode: Int, value: Int) -> Parameter {
        switch mode {
        case 0:
            return .position(value)
        case 1:
            return .immediate(value)
        case 2:
            return .relative(value)
        default:
            return .none
        }
    }
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
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                    Parameter.parse(mode: positionMode3, value: program[head + 3]),
                ]
            )
        case 2:
            operation = Operation(
                instruction: .multiply,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                    Parameter.parse(mode: positionMode3, value: program[head + 3]),
                ]
            )
        case 3:
            operation = Operation(
                instruction: .input,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                ]
            )
        case 4:
            operation = Operation(
                instruction: .output,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                ]
            )
        case 5:
            operation = Operation(
                instruction: .jumpIfTrue,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                ]
            )
        case 6:
            operation = Operation(
                instruction: .jumpIfFalse,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                ]
            )
        case 7:
            operation = Operation(
                instruction: .lessThan,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                    Parameter.parse(mode: positionMode3, value: program[head + 3]),
                ]
            )
        case 8:
            operation = Operation(
                instruction: .equals,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                    Parameter.parse(mode: positionMode3, value: program[head + 3]),
                ]
            )
        case 9:
            operation = Operation(
                instruction: .adjustRelativeBase,
                parameters: [
                    Parameter.parse(mode: positionMode1, value: program[head + 1]),
                    Parameter.parse(mode: positionMode2, value: program[head + 2]),
                    Parameter.parse(mode: positionMode3, value: program[head + 3]),
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

class IntcodeComputer {

    // MARK: - Properties

    var data: [Int]
    var head: Int
    var relativeBase: Int
    var inputs: [Int]
    var lastOutput: Int

    var isHalted = false

    // MARK: - Initialization

    init(data: [Int], inputs: [Int]) {
        self.data = data
        head = 0
        relativeBase = 0
        self.inputs = inputs

        lastOutput = 0
    }

    // MARK: - Memory Management

    private func getValue(parameter: Parameter) -> Int {
        switch parameter {
        case .immediate(let value):
            return value
        case .position(let idx):
            if idx < data.count {
                return data[idx]
            } else {
                return 0
            }
        case .relative(let idx):
            if relativeBase + idx < data.count {
                return data[relativeBase + idx]
            } else {
                return 0
            }
        case .none:
            fatalError("Illegal instruction for get value")
        }
    }

    private func setValue(value: Int, at index: Int) {
        while data.count <= index {
            data.append(0)
        }

        data[index] = value
    }

    // MARK: - Instructions

    private func add(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        setValue(value: value1 + value2, at: outputIdx)

        return head + 4
    }

    private func adjustRelativeBase(parameters: [Parameter]) -> Int {
        let value = getValue(parameter: parameters[0])

        relativeBase += value

        return head + 2
    }

    private func getDestination(parameter: Parameter) -> Int {
        switch parameter {
        case .position(let idx):
            return idx
        case .relative(let idx):
            return relativeBase + idx
        default:
            fatalError("Destination must be a position or relative")
        }
    }

    private func input(parameters: [Parameter]) -> Int {
        let outputIdx = getDestination(parameter: parameters[0])

        setValue(value: inputs.removeFirst(), at: outputIdx)

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

        let value = (value1 < value2) ? 1 : 0
        setValue(value: value, at: outputIdx)

        return head + 4
    }

    private func equals(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        let value = (value1 == value2) ? 1 : 0
        setValue(value: value, at: outputIdx)

        return head + 4
    }

    private func multiply(parameters: [Parameter]) -> Int {
        let value1 = getValue(parameter: parameters[0])
        let value2 = getValue(parameter: parameters[1])
        let outputIdx = getDestination(parameter: parameters[2])

        setValue(value: value1 * value2, at: outputIdx)

        return head + 4
    }

    private func output(parameters: [Parameter]) -> Int {
        let value = getValue(parameter: parameters[0])

        print("Output @ \(head): \(value)")
        lastOutput = value

        return head + 2
    }

    // MARK: - Running

    func add(input: Int) {
        inputs.append(input)
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
            case .adjustRelativeBase:
                nextHead = adjustRelativeBase(parameters: operation.parameters)
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

    // MARK: - Utilities

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
