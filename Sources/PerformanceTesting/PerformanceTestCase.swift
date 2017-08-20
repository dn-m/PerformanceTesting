//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import Foundation
import XCTest

// for fflush(stdout)
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

open class PerformanceTestCase: XCTestCase {

    // MARK: Nested Types

    // FIXME: Consider making this `DebugLevel`
    // FIXME: Further, consider making this a global (internal) enum
    public struct Configuration {
        // Controls whether any methods in this file print verbose (debugging) information
        public static var verbose: Bool = true
    }

    // MARK: Instance Methods

    /// Benchmarks the performance of a closure.
    public func benchmark(
        _ operation: (Int) -> Double
    ) -> Benchmark
    {
        let testPoints = Scale.medium
        let benchmarkResults = testPoints.map { testPoint -> Double in
            var result = 3.0
            if Configuration.verbose {
                // So we know exactly where we're hanging. Swift seems to only
                // flush at newlines, so manually flush here
                print("\(#function): (\(testPoint), ", terminator:"")
                fflush(stdout)
            }

            result = operation(testPoint)

            if Configuration.verbose {
                print("\(result))")
            }

            return result
        }

        let doubleTestPoints: [Double] = testPoints.map(Double.init)
        return Array(zip(doubleTestPoints, benchmarkResults))
    }

    /// Assert that the data indicates that performance is constant-time ( O(1) ).
    public func assertConstantTimePerformance(_ benchmark: Benchmark, accuracy: Double = 0.01) {

        let results = linearRegression(benchmark)

        if Configuration.verbose {
            print("\(#function): data:")
            for (x, y) in benchmark { print("\t(\(x), \(y))") }

            print("\(#function): slope:       \(results.slope)")
            print("\(#function): intercept:   \(results.intercept)")
            print("\(#function): correlation: \(results.correlation)")
            print("\(#function): slope acc.:  \(accuracy)")
        }

        XCTAssertEqual(results.slope, 0, accuracy: accuracy)
        XCTAssert(results.correlation < 0.9,
            "Constant-time performance should not have a linearly correlated slope"
        )
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

    public func assertPerformance(
        _ complexity: Complexity,
        _ operation: (Int) -> Double
    )
    {
        let data = benchmark(operation)
        switch complexity {
        case .constant:
            assertConstantTimePerformance(data)
        default:
            assertPerformanceComplexity(data, complexity: complexity)
        }
    }

    public func measure(
        _ closure: () -> Void
    ) -> Double
    {
        let measures: [Double] = (0..<10).map { _ in
            let startTime: Double = CFAbsoluteTimeGetCurrent()
            closure()
            let finishTime: Double = CFAbsoluteTimeGetCurrent()
            return finishTime - startTime
        }
        return measures.average
    }

    public func measureMutable(
        _ closure: () -> Double
    ) -> Double
    {
        let measures: [Double] = (0..<10).map { _ in closure() }
        return measures.average
    }

    public func time(
        _ closure: () -> Void
    ) -> Double
    {
        let startTime: Double = CFAbsoluteTimeGetCurrent()
        closure()
        let finishTime: Double = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
    }

/* TODO: not sure if this is needed yet
    public func time(
        repetitions: Int,
        _ closure: () -> Void
    ) -> Double
    {
        assert(repetitions > 0)
        let startTime: Double = CFAbsoluteTimeGetCurrent()
        for _ in 0..<repetitions {
            closure()
        }
        let finishTime: Double = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
    }
*/

}

extension Array where Array == Benchmark {

    /// Maps data representing performance of a certain complexity so that it
    /// can be fit with linear regression. This is done by applying the inverse
    /// function of the expected performance function.
    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return self.map { ($0, complexity.inverse($1)) }
    }
}

