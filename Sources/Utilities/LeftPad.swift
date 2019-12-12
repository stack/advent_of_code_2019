//
//  LeftPad.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved
//

import Foundation

extension String {

    public func leftPad (length: Int, character: Character = " ") -> String {
        var result: String = self

        while result.count < length {
            result.insert(character, at: result.startIndex)
        }

        return result
    }
    
}
