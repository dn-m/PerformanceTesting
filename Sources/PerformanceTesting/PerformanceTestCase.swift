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
}

/// Assert that the given `operation` scales over the given `testPoints` (i.e., `N`) within the
/// given `complexity` class.
public func assertPerformance(
    _ complexity: Complexity,
    testPoints: [Int] = Scale.medium,
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

/// Assert that the data indicates that performance is constant-time ( O(1) ).
public func assertConstantTimePerformance(_ benchmark: Benchmark, accuracy: Double = 0.01) {

    let results = linearRegression(benchmark)

    if PerformanceTestCase.Configuration.verbose {
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

    if PerformanceTestCase.Configuration.verbose {
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

/// Benchmarks the performance of a closure.
public func benchmark(_ operation: (Int) -> Double, testPoints: [Int] = Scale.medium) -> Benchmark {

    let benchmarkResults = testPoints.map { testPoint -> Double in
        var result = 3.0
        if PerformanceTestCase.Configuration.verbose {
            // So we know exactly where we're hanging. Swift seems to only
            // flush at newlines, so manually flush here
            print("\(#function): (\(testPoint), ", terminator:"")
            fflush(stdout)
        }

        result = operation(testPoint)

        if PerformanceTestCase.Configuration.verbose {
            print("\(result))")
        }

        return result
    }

    let doubleTestPoints: [Double] = testPoints.map(Double.init)
    return Array(zip(doubleTestPoints, benchmarkResults))
}

/// - Returns: The mean execution of ten iterations of the given `closure`.
///
/// - FIXME: Inject the iteraction count.
public func meanExecutionTime(_ closure: () -> Void) -> Double {
    return meanOutcome { time(closure) }
}

/// - Returns: The mean value of ten iterations of the given `closure`.
///
/// - FIXME: Perhaps these values should just be mapped into a single array first?
/// - FIXME: Maybe `10` should not be hard-coded here.
public func meanOutcome(_ closure: () -> Double) -> Double {
    return (0..<10).map { _ in closure() }.average
}

/// - Returns: The amount of time (in Seconds) that it takes to perform the given `closure`.
public func time(_ closure: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    closure()
    let finish = CFAbsoluteTimeGetCurrent()
    return finish - start
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
