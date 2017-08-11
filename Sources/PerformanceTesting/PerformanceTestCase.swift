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

    public typealias Setup <Structure> = (inout Structure, Double) -> Void
    public typealias Operation <Structure> = (inout Structure, Double) -> Void

    // MARK: Nested Types

    // FIXME: Consider making this `DebugLevel`
    // FIXME: Further, consider making this a global (internal) enum
    public struct Configuration {
        // Controls whether any methods in this file print verbose (debugging) information
        public static var verbose: Bool = true
    }

    // MARK: Instance Methods

    /// Benchmarks the performance of a closure.
    public func benchmark <Structure> (
        structure: Structure,
        setup: Setup<Structure>,
        measuring operation: Operation<Structure>,
        isMutating: Bool,
        testPoints: [Double] = Scale.medium,
        trialCount: Int = 10
    ) -> Benchmark
    {
        return testPoints.map { testPoint in
            var testPointCopy = structure
            setup(&testPointCopy, testPoint)
            let average = (0..<trialCount).map { _ in
                // if the closure is mutating, create a copy before timing the closure
                if isMutating {
                    var trialCopy = testPointCopy
                    return time(testPoint: testPoint, structure: &trialCopy, measuring: operation)
                } else {
                    return time(testPoint: testPoint, structure: &testPointCopy, measuring: operation)
                }
            }.reduce(0, +) / Double(trialCount)
            return (testPoint, average)
        }
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

    private func time <Structure> (
        testPoint: Double,
        structure: inout Structure,
        measuring operation: Operation<Structure>
    ) -> Double
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation(&structure, testPoint)
        let finishTime = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
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
