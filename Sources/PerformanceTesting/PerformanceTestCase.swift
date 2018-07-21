//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import Darwin

/// The amount of information to be emitted.
public enum Logging {

    /// No information will be emitted.
    case none

    /// High-level information for a performance test of a single operation.
    case overview

    /// Information for each trial of a performance tests of a single operation.
    case detailed
}

/// Assert that the computed average time complexity of a `benchmark` is in the stated complexity
/// class on the scale of inputs.
public func assertPerformance(_ complexity: Complexity, of benchmark: Benchmark) {
    let data = benchmark.data
    switch complexity {
    case .constant:
        assertConstantTimePerformance(data, logging: .none)
    default:
        assertPerformanceComplexity(data, complexity: complexity, logging: .none)
    }
}

/// Assert that the data indicates that performance is constant-time ( O(1) ).
internal func assertConstantTimePerformance(
    _ benchmark: [(Double,Double)],
    tolerance: Double = 0.01,
    logging: Logging = .none
)
{
    let results = linearRegression(benchmark)
    guard approximatelyEqual(results.slope, 0, epsilon: tolerance) || results.correlation < 0.9 else {
        dump(benchmark)
        dump(results)
        XCTFail("Operation not observed in constant time")
        return
    }
}

/// Assert that the data indicates that performance fits well to the given
/// complexity class. Optional parameter for minimum acceptable correlation.
/// Use assertConstantTimePerformance for O(1) assertions
internal func assertPerformanceComplexity(
    _ benchmark: [(Double,Double)],
    complexity: Complexity,
    minimumCorrelation: Double = 0.9,
    logging: Logging = .none
)
{
    let mappedData = benchmark.mappedForLinearFit(complexity: complexity)
    let results = linearRegression(mappedData)
    guard results.correlation >= minimumCorrelation else {
        dump(benchmark)
        dump(results)
        XCTFail("Operation not observed in \(complexity) time")
        return
    }
}

extension Array where Element == (Double,Double) {

    /// Maps data representing performance of a certain complexity so that it
    /// can be fit with linear regression. This is done by applying the inverse
    /// function of the expected performance function.
    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return self.map { ($0, complexity.inverse($1)) }
    }
}

extension Array {

    /// Fills the array using a generator function. The function
    /// is passed the index of the current element as an argument.
    public init(count: Int, fillingWith generator: (Int) -> Element) {
        self.init()
        reserveCapacity(count)
        for i in 0..<count { append(generator(i)) }
    }
}

extension Set {

    /// Fills the array using a generator function. The function
    /// is passed the index of the current element as an argument.
    public init(count: Int, fillingWith generator: (Int) -> Element) {
        self.init()
        reserveCapacity(count)
        for i in 0..<count { insert(generator(i)) }
    }
}

extension Dictionary {

    /// Fills the array using a generator function. The function
    /// is passed the index of the current element as an argument.
    public init(count: Int, fillingWith generator: (Int) -> Element) {
        self.init(minimumCapacity: count)
        for i in 0..<count {
            let element = generator(i)
            updateValue(element.value, forKey: element.key)
        }
    }
}

/// - Returns: `true`  if the given values are equal within the given `epsilon`. Otherwise, `false.`
///
/// - Note: This is a naive implementation which does not address extreme floating point situations.
public func approximatelyEqual <F: FloatingPoint> (_ a: F, _ b: F, epsilon: F) -> Bool {
    if a == b { return true }
    return abs(b-a) < epsilon
}
