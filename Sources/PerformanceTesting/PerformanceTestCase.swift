//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import XCTest

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
public func assertPerformance <Subject> (_ complexity: Complexity, of benchmark: Benchmark<Subject>) {
    let data = benchmark.data
    switch complexity {
    case .constant:
        assertConstantTimePerformance(data, logging: .none)
    default:
        assertPerformanceComplexity(data, complexity: complexity, logging: .none)
    }
}

/// Assert that the computed average time complexity of `operation` is in the stated complexity
/// class on the scale of inputs denoted by `testPoints`.
///
/// - TODO: Add injection point (and default) for number of trials
#warning("assertPerformance():testPoints:logging:of:) is only a dependent of a few remaining tests.")
#warning("TODO: Work to remove.")
public func assertPerformance(
    _ complexity: Complexity,
    testPoints: [Int] = Scale.medium,
    logging: Logging = .none,
    of operation: (Int) -> Double
)
{
    let data = benchmark(operation, testPoints: testPoints)
    switch complexity {
    case .constant:
        assertConstantTimePerformance(data, logging: logging)
    default:
        assertPerformanceComplexity(data, complexity: complexity, logging: logging)
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

    if logging == .detailed {
        for (trial,info) in benchmark.enumerated() {
            let (size,time) = info
            print("trial \(trial + 1): size: \(size), time: \(time)")
        }
        print("slope: \(results.slope) (tolerance: \(tolerance))")
        print("intercept: \(results.intercept)")
        print("correlation: \(results.correlation)")
    }
    XCTAssertEqual(results.slope, 0, accuracy: tolerance)
    XCTAssert(
        results.correlation < 0.9,
        "Constant-time performance should not have a linearly correlated slope"
    )
}

/// Assert that the data indicates that performance fits well to the given
/// complexity class. Optional parameter for minimum acceptable correlation.
/// Use assertConstantTimePerformance for O(1) assertions
internal func assertPerformanceComplexity(
    _ data: [(Double,Double)],
    complexity: Complexity,
    minimumCorrelation: Double = 0.9,
    logging: Logging = .none
)
{
    let mappedData = data.mappedForLinearFit(complexity: complexity)
    let results = linearRegression(mappedData)
    if logging == .detailed  {
        for (trial,info) in mappedData.enumerated() {
            let (size,time) = info
            print("trial: \(trial + 1): size: \(size), time: \(time)")
        }
        print("slope: \(results.slope)")
        print("intercept: \(results.intercept)")
        print("correlation: \(results.correlation) (minimum: \(minimumCorrelation))")
    }
    XCTAssert(results.correlation >= minimumCorrelation)
}

/// Benchmarks the performance of a closure.
#warning("benchmark(_:testPoints:logging:) is only required by assertPerformance():testPoints:logging:of:).")
#warning("Remove when the other is let go.")
public func benchmark(
    _ operation: (Int) -> Double,
    testPoints: [Int] = Scale.medium,
    logging: Logging = .none
) -> [(Double,Double)]
{
    let benchmarkResults = testPoints.map { testPoint in operation(testPoint) }
    let doubleTestPoints = testPoints.map(Double.init)
    return Array(zip(doubleTestPoints, benchmarkResults))
}

/// - Returns: The mean execution of ten iterations of the given `closure`.
///
/// - FIXME: Inject the iteration count.
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

extension Array where Array == [(Double,Double)] {

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
