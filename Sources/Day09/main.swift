//
//  main.swift
//  Day 08
//
//  Created by Stephen H. Gerstacker on 2019-12-08.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

// let program = Data.sampleData1
// let program = Data.sampleData2
// let program = Data.sampleData3
let program = Data.inputData

// let inputs = Data.sampleInputs1
// let inputs = Data.sampleInputs2
// let inputs = Data.sampleInputs3
// let inputs = Data.input1Inputs
let inputs = Data.input2Inputs

let computer = IntcodeComputer(data: program, inputs: inputs)

while true {
    computer.run()

    if computer.isHalted {
        break
    }

    let output = computer.lastOutput
    print("Output: \(output)")
}
