//
//  IntcodeComputerTests.swift
//  UtilitiesTests
//
//  Created by Stephen H. Gerstacker on 2019-12-09.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import XCTest

@testable import Utilities

class IntcodeComputerTests: XCTestCase {

    func testDay02Sample01() {
        let program = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        XCTAssertTrue(computer.isHalted)

        let value = computer.getValue(parameter: .position(0))
        XCTAssertEqual(value, 3500)
    }

    func testDay02Sample02() {
        let program = [1, 0, 0, 0, 99]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        XCTAssertTrue(computer.isHalted)

        let value = computer.getValue(parameter: .position(0))
        XCTAssertEqual(value, 2)
    }

    func testDay02Sample03() {
        let program = [2, 3, 0, 3, 99]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        XCTAssertTrue(computer.isHalted)

        let value = computer.getValue(parameter: .position(3))
        XCTAssertEqual(value, 6)
    }

    func testDay02Sample04() {
        let program = [2, 4, 4, 5, 99, 0]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        XCTAssertTrue(computer.isHalted)

        let value = computer.getValue(parameter: .position(5))
        XCTAssertEqual(value, 9801)
    }

    func testDay02Sample05() {
        let program = [1, 1, 1, 4, 99, 5, 6, 0, 99]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        XCTAssertTrue(computer.isHalted)

        let value = computer.getValue(parameter: .position(0))
        XCTAssertEqual(value, 30)
    }

    func testDay05Sample01() {
        let program = [1002, 4, 3, 4, 33]

        let computer = IntcodeComputer(data: program, inputs: [0])
        computer.run()

        XCTAssertTrue(computer.isHalted)
    }

    func testDay05Sample02() {
        let program = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8] // Is input 8?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 0)

        let computer2 = IntcodeComputer(data: program, inputs: [8])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 1)
    }

    func testDay05Sample03() {
        let program = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8] // Is input less than 8?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 1)

        let computer2 = IntcodeComputer(data: program, inputs: [8])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 0)
    }

    func testDay05Sample04() {
        let program = [3, 3, 1108, -1, 8, 3, 4, 3, 99] // Is input 8?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 0)

        let computer2 = IntcodeComputer(data: program, inputs: [8])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 1)
    }

    func testDay05Sample05() {
        let program = [3, 3, 1107, -1, 8, 3, 4, 3, 99] // Is input less than 8?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 1)

        let computer2 = IntcodeComputer(data: program, inputs: [8])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 0)
    }

    func testDay05Sample06() {
        let program = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9] // Is input non-zero?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 1)

        let computer2 = IntcodeComputer(data: program, inputs: [0])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 0)
    }

    func testDay05Sample07() {
        let program = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1] // Is the input non-zero?

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 1)

        let computer2 = IntcodeComputer(data: program, inputs: [0])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 0)
    }

    func testDay05Sample08() {
        let program = [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31,  1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104,  999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99] // Input < 8,  999. Input == 8,  1000,  Input > 8,  1001

        let computer1 = IntcodeComputer(data: program, inputs: [7])
        computer1.run()

        let output1 = computer1.lastOutput
        XCTAssertEqual(output1, 999)

        let computer2 = IntcodeComputer(data: program, inputs: [8])
        computer2.run()

        let output2 = computer2.lastOutput
        XCTAssertEqual(output2, 1000)

        let computer3 = IntcodeComputer(data: program, inputs: [9])
        computer3.run()

        let output3 = computer3.lastOutput
        XCTAssertEqual(output3, 1001)
    }

    func testDay09Sample01() {
        let program = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

        let computer = IntcodeComputer(data: program, inputs: [])

        var outputs: [Int] = []

        while true {
            computer.run()

            if computer.isHalted {
                break
            }

            outputs.append(computer.lastOutput)
        }

        XCTAssertEqual(outputs, program)
    }

    func testDay09Sample02() {
        let program = [1102, 34915192, 34915192, 7, 4, 7, 99, 0]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        let output = computer.lastOutput
        XCTAssertEqual(output, 1219070632396864)
    }

    func testDay09Sample03() {
        let program = [104, 1125899906842624, 99]

        let computer = IntcodeComputer(data: program, inputs: [])
        computer.run()

        let output = computer.lastOutput
        XCTAssertEqual(output, 1125899906842624)
    }
    
}
