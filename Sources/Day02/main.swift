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

let mode: Mode = .first

var data = Data.input
let inputs = Data.inputInputs

switch mode {
case .none:
    let program = IntcodeComputer(data: data, inputs: [])
    program.run()

    let output = program.getValue(parameter: .position(0))
    print("Output: \(output)")
case .first:
    for (idx, input) in inputs.enumerated() {
        data[idx + 1] = input
    }

    let program = IntcodeComputer(data: data, inputs: [])
    program.run()

    let output = program.getValue(parameter: .position(0))
    print("Output: \(output)")
case .second:
    var complete = false

    for noun in 0 ... 99 {
        for verb in 0 ... 99 {
            data[1] = noun
            data[2] = verb

            let program = IntcodeComputer(data: data, inputs: [])
            program.run()

            let output = program.getValue(parameter: .position(0))
            print("Output: \(output)")

            if output == 19690720 {
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
