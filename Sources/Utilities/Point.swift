//
//  Point.swift
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2019-12-15.
//  Copyright © 2019 Stephen H. Gerstacker. All rights reserved.
//

import Foundation

public struct Point: Equatable, Hashable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public static var zero: Point {
        return Point(x: 0, y: 0)
    }

    public static var max: Point {
        return Point(x: .max, y: .max)
    }

    public static var min: Point {
        return Point(x: .min, y: .min)
    }

    public var distanceFromOrigin: Int {
        return abs(x) + abs(y)
    }
}

extension Point: CustomStringConvertible {

    public var description: String {
        return "{\(x), \(y)}"
    }
}
