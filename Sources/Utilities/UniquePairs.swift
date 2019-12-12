//
//  UniquePairs.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-12.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public extension Collection where Iterator.Element: Comparable & Hashable{

    func uniquePairs() -> [(Iterator.Element, Iterator.Element)] {
        var set: Set<[Iterator.Element]> = []

        for i in self {
            for j in self {
                guard i != j else {
                    continue
                }

                let pair = [i, j].sorted()
                set.insert(pair)
            }
        }

        return set.map { ($0[0], $0[1]) }.sorted {
            if $0.0 == $1.0 {
                return $0.1 < $1.1
            } else {
                return $0.0 < $1.0
            }
        }
    }

}
