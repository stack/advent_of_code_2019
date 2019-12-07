//
//  Permutations.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-01.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
    var scratch = Array(items)
    var result: [[C.Iterator.Element]] = []

    // Heap's algorithm
    func heap(_ n: Int) {
        if n == 1 {
            result.append(scratch)
            return
        }

        for i in 0 ..< n-1 {
            heap(n-1)
            let j = (n % 2 == 1) ? 0 : i
            scratch.swapAt(j, n - 1)
        }
        heap(n-1)
    }

    // Let's get started
    heap(scratch.count)

    // And return the result we built up
    return result
}
