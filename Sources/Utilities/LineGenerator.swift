//
//  LineGenerator.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-01.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public func lineGenerator(fileHandle: FileHandle) -> AnyIterator<String> {
    guard let file = fdopen(fileHandle.fileDescriptor, "r") else {
        fatalError("Failed to open file for line generation")
    }

    return AnyIterator { () -> String? in
        var line: UnsafeMutablePointer<Int8>? = nil
        var linecap: Int = 0

        let written = getline(&line, &linecap, file)

        if written > 0 {
            let result = String(utf8String: line!)
            free(line)

            return result?.trimmingCharacters(in: .newlines)
        } else {
            fclose(file)
            return nil
        }
    }

}
