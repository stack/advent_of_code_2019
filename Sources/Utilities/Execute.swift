//
//  Execute.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-06.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public func execute(command: String, arguments: [String], callback: ((Pipe, Pipe, Pipe) -> ())?) {
    let inputPipe = Pipe()
    let outputPipe = Pipe()
    let errorPipe = Pipe()

    let process = Process()
    process.arguments = arguments
    process.executableURL = URL(fileURLWithPath: command)
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    process.standardError = errorPipe

    process.terminationHandler = { process -> () in
        print("Process terminated: \(process.terminationStatus)")
    }

    try! process.run()

    callback?(inputPipe, outputPipe, errorPipe)

    process.waitUntilExit()
}
