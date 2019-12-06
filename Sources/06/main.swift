//
//  main.swift
//  Day 06
//
//  Created by Stephen H. Gerstacker on 2019-12-06.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation
import Utilities

class Object {
    let name: String
    var parent: Object?
    var children: Set<Object>

    var totalOrbits: Int {
        var current = parent
        var count = 0

        while current != nil {
            current = current?.parent
            count += 1
        }

        return count
    }

    init(name: String) {
        self.name = name

        parent = nil
        children = []
    }
}

extension Object: Equatable {
    static func ==(lhs: Object, rhs: Object) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Object: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// Set the input data
// let data = Data.sampleData1
// let data = Data.sampleData2
let data = Data.inputData

// Build storage for all objects
var objects: [String:Object] = [:]

// Convert data in to something useful
let parsedData = data.map { (value: String) -> (String, String) in
    let parts = value.split(separator: ")")
    let parent = String(parts[0])
    let child = String(parts[1])

    return (parent, child)
}

// For each object, add it empty to storage
for (parent, child) in parsedData {
    objects[parent] = Object(name: parent)
    objects[child] = Object(name: child)
}

// Link each object in storage to its orbit
for (parent, child) in parsedData {
    let parent = objects[parent]!
    let child = objects[child]!

    child.parent = parent
    parent.children.insert(child)
}

// Calculate the checksum
let checksum = objects.reduce(0) { (sum, current) -> Int in
    let (key, value) = current

    let total = value.totalOrbits
    print("\(key) -> \(total)")

    return sum + total
}

print("Checksum: \(checksum)")

let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
let outputPath = desktopPath + "/06-graph.pdf"

let arguments = ["-o", outputPath, "-Tpdf"]
execute(command: "/usr/local/bin/dot", arguments: arguments) { (inputPipe, outputPipe, errorPipe) in
    let handle = inputPipe.fileHandleForWriting

    handle.write(string: "digraph {\n")

    handle.write(string: "  node [fontname=Future]\n")
    handle.write(string: "  YOU [shape=box, style=filled, color=yellow]\n")
    handle.write(string: "  SAN [shape=diamond, style=filled, color=red]\n")

    for (_, object) in objects {
        if let parent = object.parent {
            handle.write(string: "  \"\(object.name)\" -> \"\(parent.name)\"\n")
        }
    }

    handle.write(string: "}")
    handle.closeFile()

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let outputString = String(bytes: outputData, encoding: .utf8)

    if let output = outputString, !output.isEmpty {
        print(output)
    }

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let errorString = String(bytes: errorData, encoding: .utf8)

    if let error = errorString, !error.isEmpty {
        print(error)
    }
}
