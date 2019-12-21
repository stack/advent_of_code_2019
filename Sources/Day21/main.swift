//
//  main.swift
//  Day 21
//
//  Created by Stephen H. Gerstacker on 2019-12-21.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

enum Mode {
    case walk
    case run
}

let data = Data.input
let script = Data.script2
let mode: Mode = .run

func run(data: [Int], script: String, mode: Mode) -> Int? {
    let finalScript: String

    switch mode {
    case .walk:
        finalScript = script + "\nWALK\n"
    case .run:
        finalScript = script + "\nRUN\n"
    }

    let scriptBytes = Array(finalScript.utf8).map { Int($0) }

    let program = IntcodeComputer(data: data, inputs: scriptBytes)

    while true {
        program.run()

        if program.isHalted {
            break
        }

        if program.hasOutput {
            let output = program.getOutput()

            if output > 255 {
                return output
            } else if output == 10 {
                print()
            } else {
                print(String(UnicodeScalar(UInt8(output))), terminator: "")
            }
        }
    }

    return nil
}

guard let output = run(data: data, script: script, mode: mode) else {
    fatalError("Failed to make it")
}

print("Output: \(output)")
