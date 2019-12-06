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

extension Object: CustomStringConvertible {
    var description: String {
        return name
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

func drawGraph(name: String, objects: [String:Object], highlights: [Object] = []) {
    let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
    let outputPath = desktopPath + "/" + name

    let arguments = ["-o", outputPath, "-Tpdf"]
    execute(command: "/usr/local/bin/dot", arguments: arguments) { (inputPipe, outputPipe, errorPipe) in
        let handle = inputPipe.fileHandleForWriting

        handle.write(string: "digraph {\n")
        handle.write(string: "  rankdir=\"RL\"\n")
        handle.write(string: "  bgcolor=\"#2C2C2E\"\n")

        handle.write(string: "  edge [color=\"#EBEBF5\"]\n")
        handle.write(string: "  node [fontname=Helvetica, shape=circle, style=filled, color=white, fillcolor=\"#EBEBF5\"]\n")
        handle.write(string: "  YOU [fillcolor=\"#FFD60A\"]\n")
        handle.write(string: "  SAN [fillcolor=\"#FF453A\"]\n")

        for highlight in highlights where highlight.name != "YOU" {
            handle.write(string: "  \"\(highlight.name)\" [fillcolor=\"#30D158\"]\n")
        }

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

drawGraph(name: "06-graph.pdf", objects: objects)

guard let youObject = objects["YOU"] else {
    print("No YOU object. Exiting early")
    exit(0)
}

guard let santaObject = objects["SAN"] else {
    print("No SAN object. Exiting early")
    exit(0)
}

// A* search for the shortest path
var frontier = PriorityQueue<Object>()
var cameFrom: [Object:Object] = [:]
var costSoFar: [Object:Int] = [:]

frontier.push(youObject, priority: 0)
costSoFar[youObject] = 0

while !frontier.isEmpty {
    guard let current = frontier.pop() else {
        print("Ran out of frontier to explore")
        exit(1)
    }

    if current == santaObject {
        break
    }

    var nextObjects = current.children

    if let parent = current.parent {
        nextObjects.insert(parent)
    }

    for nextObject in nextObjects {
        let newCost = costSoFar[current]! + 1

        if costSoFar[nextObject] == nil || newCost < costSoFar[nextObject]! {
            costSoFar[nextObject] = newCost
            frontier.push(nextObject, priority: newCost)
            cameFrom[nextObject] = current
        }
    }
}

var current = santaObject
var path: [Object] = []

while current != youObject {
    guard let nextObject = cameFrom[current] else {
        fatalError("Broken path")
    }

    path.append(nextObject)
    current = nextObject
}

print("Path: \(path)")
print("Distance from YOU -> SAN: \(path.count - 2)") // Path contains YOU and YOU's current orbit

drawGraph(name: "06-graph-path.pdf", objects: objects, highlights: path)
