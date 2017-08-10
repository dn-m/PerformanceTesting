//
//  Scale.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/10/17.
//

import Darwin

/// Ranges of values to use for testPoints (values of `n` in `O(f(n))`).
public struct Scale {
    public static let tiny   = exponentialSeries(size: 10, from: 5,    to: 100)
    public static let small  = exponentialSeries(size: 10, from: 10,   to: 1_000)
    public static let medium = exponentialSeries(size: 10, from: 100,  to: 1_000_000)
    public static let large  = exponentialSeries(size: 10, from: 1000, to: 1_000_000_000)
}

// Creates an array of Doubles in an exponential series.
private func exponentialSeries(size: Int, from start: Double, to end: Double) -> [Double] {
    let base = pow(end - start + 1, 1 / (Double(size)-1))
    return (0..<size).map { pow(base, Double($0)) + start - 1 }.map(round)
}
