//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import Foundation
import XCTest

open class PerformanceTestCase: XCTestCase {

    // MARK: Associated Types

    public typealias Setup<C> = (inout C, Double) -> Void
    public typealias Run<C> = (inout C, Double) -> Void

    // MARK: Nested Types

    // FIXME: Consider making this `DebugLevel`
    // FIXME: Further, consider making this a global (internal) enum
    public struct Configuration {
        // Controls whether any methods in this file print verbose (debugging) information
        public static var verbose: Bool = true
    }

    // MARK: Instance Methods

    /// Benchmarks the performance of a closure.
    public func benchmark <C> (
        mock object: C,
        setup: Setup<C>,
        measuring closure: Run<C>,
        isMutating: Bool,
        testPoints: [Double] = Scale.medium,
        trialCount: Int = 10
    ) -> Benchmark
    {
        return testPoints.map { testPoint in
            var pointMock = object
            setup(&pointMock, testPoint)
            let average = (0..<trialCount).map { _ in
                // if the closure is mutating, create a copy before timing the closure
                if isMutating {
                    var trialMock = pointMock
                    return time(testPoint: testPoint, mock: &trialMock, measuring: closure)
                } else {
                    return time(testPoint: testPoint, mock: &pointMock, measuring: closure)
                }
            }.reduce(0, +) / Double(trialCount)
            return (testPoint, average)
        }
    }

    private func time <C> (
        testPoint: Double,
        mock: inout C,
        measuring closure: Run<C>
    ) -> Double
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        closure(&mock, testPoint)
        let finishTime = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
    }

    /// Assert that the data indicates that performance is constant-time ( O(1) ).
    public func assertConstantTimePerformance(
        _ benchmark: Benchmark,
        slopeAccuracy: Double = 0.01
    )
    {
        let results = linearRegression(benchmark)

        if Configuration.verbose {
            print("\(#function): data:")
            for (x, y) in benchmark { print("\t(\(x), \(y))") }

            print("\(#function): slope:       \(results.slope)")
            print("\(#function): intercept:   \(results.intercept)")
            print("\(#function): correlation: \(results.correlation)")
            print("\(#function): slope acc.:  \(slopeAccuracy)")
        }

        XCTAssertEqual(results.slope, 0, accuracy: slopeAccuracy)
    }

    /// Assert that the data indicates that performance fits well to the given
    /// complexity class. Optional parameter for minimum acceptable correlation.
    /// Use assertConstantTimePerformance for O(1) assertions
    public func assertPerformanceComplexity(
        _ data: Benchmark,
        complexity: Complexity,
        minimumCorrelation: Double = 0.9
    )
    {
        let mappedData = data.mappedForLinearFit(complexity: complexity)
        let results = linearRegression(mappedData)

        if Configuration.verbose {
            print("\(#function): mapped data:")
            for (x, y) in mappedData { print("\t(\(x), \(y))") }

            print("\(#function): slope:       \(results.slope)")
            print("\(#function): intercept:   \(results.intercept)")
            print("\(#function): correlation: \(results.correlation)")
            print("\(#function): min corr.:   \(minimumCorrelation)")
        }

        switch complexity {
        case .constant:
            print("\(#function): warning: constant-time complexity is not well-supported. You",
                "probably mean assertConstantTimePerformance")
        default:
            break
        }

        XCTAssert(results.correlation >= minimumCorrelation)
    }
}

/// Maps data representing performance of a certain complexity so that it
/// can be fit with linear regression. This is done by applying the inverse
/// function of the expected performance function.
extension Array where Array == Benchmark {
    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return self.map { ($0, complexity.inverse($1)) }
    }
}
