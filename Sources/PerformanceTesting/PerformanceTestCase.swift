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

    /// - Returns: An array of two-tuples containing the size of the structure and the average time
    /// taken to perform the given `operation`.
    public func benchmark <Structure> (
        structure: Structure,
        setup: Setup<Structure>,
        measuring operation: Operation<Structure>,
        testPoints: [Double] = Scale.medium,
        trialCount: Int = 10
    ) -> Benchmark
    {
        let tests: [PerformanceTest] = testPoints.map { testPoint in
            var testPointCopy = structure
            setup(&testPointCopy, testPoint)
            let results: [Double] = (0..<trialCount).map { _ in
                var trialCopy = testPointCopy
                return measure(operation, on: &trialCopy, for: testPoint)
            }
            return PerformanceTest(size: Int(testPoint), results: results)
        }
        return Benchmark(tests: tests)
    }

    public func assertConstantTimePerformance(_ benchmark: Benchmark, accuracy: Double = 0.01) {
        assertConstantTimePerformance(benchmark.data)
    }

    /// Assert that the data indicates that performance is constant-time ( O(1) ).
    public func assertConstantTimePerformance(_ data: [(Double,Double)], accuracy: Double = 0.01) {

        let results = linearRegression(data)

        if Configuration.verbose {
            print("\(#function): data:")
            for (x, y) in data { print("\t(\(x), \(y))") }

            print("\(#function): slope:       \(results.slope)")
            print("\(#function): intercept:   \(results.intercept)")
            print("\(#function): correlation: \(results.correlation)")
            print("\(#function): slope acc.:  \(accuracy)")
        }

        XCTAssertEqual(results.slope, 0, accuracy: accuracy)
    }

    public func assertPerformanceComplexity(_ benchmark: Benchmark, complexity: Complexity, minimumCorrelation: Double = 0.9) {
        assertPerformanceComplexity(benchmark.data, complexity: complexity, minimumCorrelation: minimumCorrelation)
    }

    /// Assert that the data indicates that performance fits well to the given
    /// complexity class. Optional parameter for minimum acceptable correlation.
    /// Use assertConstantTimePerformance for O(1) assertions
    public func assertPerformanceComplexity(
        _ data: [(Double,Double)],
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

    private func measure <Structure> (
        _ operation: Operation<Structure>,
        on structure: inout Structure,
        for testPoint: Double
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
extension Array where Array == [(Double,Double)] {

    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return map { ($0, complexity.inverse($1)) }
    }
}

extension Array where Element == Double {

    public var sum: Double {
        return reduce(0,+)
    }

    public var average: Double {
        assert(count > 0)
        return sum / Double(count)
    }
}
