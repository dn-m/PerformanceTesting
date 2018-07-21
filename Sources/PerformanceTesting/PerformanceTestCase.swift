//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import Darwin

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
            let tolerance = 0.01
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
