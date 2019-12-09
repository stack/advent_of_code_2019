//
//  main.swift
//  Day 07
//
//  Created by Stephen H. Gerstacker on 2019-12-07.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let program1 = Data.inputProgram
let sequences1 = Data.inputSequences1

let program2 = Data.inputProgram
let sequences2 = Data.inputSequences2

func part1(program: [Int], sequences: [[Int]]) {
    var maxSequence: [Int] = []
    var maxOutput: Int = 0

    for sequence in sequences {
        print("Sequence: \(sequence)")

        var output = 0

        let amps = sequence.map { IntcodeComputer(data: program, inputs: [$0]) }

        for amp in amps {
            amp.add(input: output)
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
}

func part2(program: [Int], sequences: [[Int]]) {
    var maxSequence: [Int] = []
    var maxOutput: Int = 0

    for sequence in sequences {
        print("Sequence: \(sequence)")

        var output = 0

        var amps = sequence.map { IntcodeComputer(data: program, inputs: [$0]) }

        while true {
            let amp = amps.removeFirst()

            amp.add(input: output)
            amp.run()

            output = amp.lastOutput

            amps.append(amp)

            let halted = amps.reduce(true, { $0 && $1.isHalted })
            if halted {
                break
            }
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
}

part1(program: program1, sequences: sequences1)
part2(program: program2, sequences: sequences2)
