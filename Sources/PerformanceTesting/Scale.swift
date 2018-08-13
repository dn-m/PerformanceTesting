//
//  Scale.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/10/17.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

/// Ranges of values to use for testPoints (values of `n` in `O(f(n))`).
public struct Scale {
    public static let tiny   = exponentialSeries(size: 10, from: 5,    to: 100)
    public static let small  = exponentialSeries(size: 10, from: 10,   to: 1_000)
    public static let medium = exponentialSeries(size: 10, from: 100,  to: 1_000_000)
    public static let large  = exponentialSeries(size: 10, from: 1000, to: 1_000_000_000)
}

// Creates an array of rounded Ints in an approximate exponential series.
private func exponentialSeries(size: Int, from start: Int, to end: Int) -> [Int] {
    let range = Double(end - start + 1)
    let base = pow(range, 1 / (Double(size)-1))
    let floatingPointSeries = (0..<size).map { pow(base, Double($0)) + Double(start) - 1 }

    // round first to avoid truncation
    return floatingPointSeries.map { Int(round($0)) }
}
