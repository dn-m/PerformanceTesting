//
//  IntExtensions.swift
//  PerformanceTestingTests
//
//  Created by Brian Heim on 8/21/17
//

import Foundation

extension Int {

    /// - Returns: a uniform random number in the range [0, self)
    public func random() -> Int {
        assert(self >= 0)
        return Int(arc4random_uniform(UInt32(self)))
    }
}

