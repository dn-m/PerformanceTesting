//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import Darwin

/// Assert that the data indicates that performance is constant-time ( O(1) ).
internal func assertConstantTimePerformance(
    _ benchmark: [(Double,Double)],
    tolerance: Double = 0.01
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
    minimumCorrelation: Double = 0.9
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

extension Array where Element == (Double, Double) {

    /// Maps data representing performance of a certain complexity so that it
    /// can be fit with linear regression. This is done by applying the inverse
    /// function of the expected performance function.
    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return map { ($0, complexity.inverse($1)) }
    }

    /// - Returns: `true` if the curve of this data resembles the given `complexity` curve.
    /// Otherwise, returns `false`.
    public func curve(is complexity: Complexity) -> Bool {
        switch complexity {
        case .constant:
            let tolerance = 0.1
            let results = linearRegression(self)
            return (
                approximatelyEqual(results.slope, 0, epsilon: tolerance) ||
                results.correlation < 0.9
            )
        default:
            let minimumCorrelation = 0.9
            let mappedData = self.mappedForLinearFit(complexity: complexity)
            let results = linearRegression(mappedData)
            return results.correlation >= minimumCorrelation
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
