//
//  main.swift
//  Day 05
//
//  Created by Stephen H. Gerstacker on 2019-12-05.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let programData = Data.input
let input = Data.inputInput2

let program = IntcodeComputer(data: programData, inputs: [input])
program.run()

while true {
    program.run()

    if program.isHalted {
        break
    }
}

let output = program.lastOutput
print("Output: \(output)")
