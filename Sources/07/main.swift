//
//  main.swift
//  Day 07
//
//  Created by Stephen H. Gerstacker on 2019-12-07.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let sequences = Data.inputSequence
let program = Data.inputProgram

var maxSequence: [Int] = []
var maxOutput: Int = 0

for sequence in sequences {
    print("Sequence: \(sequence)")

    var output = 0

    for phase in sequence {
        let inputs = [phase, output]

        let amp = Amp(data: program, inputs: inputs)
        amp.run()

        output = amp.lastOutput
    }

    print("Output: \(output)")

    if output > maxOutput {
        print("Max Output is now \(output)")
        maxSequence = sequence
        maxOutput = output
    }
}

print("Max Sequence: \(maxSequence)")
print("Max Output: \(maxOutput)")
