//
//  main.swift
//  Day 23
//
//  Created by Stephen H. Gerstacker on 2019-12-23.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

let program = Data.input

let computers = (0 ..< 50).map { IntcodeComputer(data: program, inputs: [$0]) }
var outputs = [[Int]](repeating: [], count: 50)

var lastNatX: Int = .min
var lastNatY: Int = .min
var currentNatX: Int = .min
var currentNatY: Int = .min
var natCount: Int = 0

var keepRunning = true

while keepRunning {
    var idleCount = 0

    for (idx, computer) in computers.enumerated() {
        computer.run()

        if computer.hasOutput {
            outputs[idx].append(computer.getOutput())

            if outputs[idx].count == 3 {
                let address = outputs[idx][0]
                let x = outputs[idx][1]
                let y = outputs[idx][2]

                outputs[idx].removeAll(keepingCapacity: true)

                if address == 255 {
                    currentNatX = x
                    currentNatY = y

                    if natCount == 0 {
                        print("First Y to NAT? \(currentNatY)")
                    }

                    natCount += 1
                } else {
                    computers[address].add(input: x)
                    computers[address].add(input: y)
                }
            }

        } else if computer.needsInput {
            computer.add(input: -1)
            idleCount += 1
        }
    }

    if idleCount == computers.count && natCount > 0 {
        print("NAT sending \(currentNatX), \(currentNatY)")
        computers[0].add(input: currentNatX)
        computers[0].add(input: currentNatY)

        if currentNatX == lastNatX && currentNatY == lastNatY {
            print("First NAT Y repetition? \(currentNatY)")
            keepRunning = false
        }

        lastNatX = currentNatX
        lastNatY = currentNatY
    }
}
