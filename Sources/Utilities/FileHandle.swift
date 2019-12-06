//
//  FileHandle.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-06.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public extension FileHandle {

    func write(string: String) {
        write(string.data(using: .utf8)!)
    }
    
}
