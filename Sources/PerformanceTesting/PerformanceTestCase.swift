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
        _ operation: (Int) -> Double,
        testPoints: [Int] = Scale.medium
    ) -> Benchmark
    {
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

    public func assertPerformance(_ complexity: Complexity, of operation: (Int) -> Double) {
        let data = benchmark(operation)
        switch complexity {
        case .constant:
            assertConstantTimePerformance(data)
        default:
            assertPerformanceComplexity(data, complexity: complexity)
        }
    }

    public func assertPerformance(
        _ complexity: Complexity,
        testPoints: [Int],
        of operation: (Int) -> Double
    )
    {
        let data = benchmark(operation, testPoints: testPoints)
        switch complexity {
        case .constant:
            assertConstantTimePerformance(data)
        default:
            assertPerformanceComplexity(data, complexity: complexity)
        }
    }

    public func meanExecutionTime(_ closure: () -> Void) -> Double {
        return meanOutcome { time(closure) }
    }

    public func meanOutcome(_ closure: () -> Double) -> Double {
        return (0..<10).map { _ in closure() }.average
    }

    public func time(_ closure: () -> Void) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        closure()
        let finishTime = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
    }
}

extension Array where Array == Benchmark {

    /// Maps data representing performance of a certain complexity so that it
    /// can be fit with linear regression. This is done by applying the inverse
    /// function of the expected performance function.
    public func mappedForLinearFit(complexity: Complexity) -> Array {
        return self.map { ($0, complexity.inverse($1)) }
    }
}

extension Array {

    /// Initializer that fills the array using a generator function. The function
    /// is passed the index of the current element as an argument.
    public init(count: Int, fillingWith elementGenerator: (Int) -> Element) {
        self.init()
        reserveCapacity(count)
        for i in 0..<count {
            append(elementGenerator(i))
        }
    }

}
