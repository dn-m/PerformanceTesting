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
    public typealias Benchmark = [(Double, Double)]

    // MARK: Nested Types

    public struct Configuration {
        // Controls whether any methods in this file print verbose (debugging) information
        public static var verbose: Bool = true
    }

    /// Classes of complexity (big-oh style).
    public enum Complexity {

        case constant
        case logarithmic
        case squareRoot
        case linear
        case quadratic
        case cubic
        case exponential
        case customComplexity(inverseFunction: (Double) -> Double)

        /// The inverse function of the function represented by this complexity.
        /// For example, the inverse of squareRoot is squaring.
        public var inverse: (Double) -> Double {
            switch self {
            case .constant:
                return { $0 }
            case .logarithmic:
                return exp
            case .squareRoot:
                return { pow($0, 2) }
            case .linear:
                return { $0 }
            case .quadratic:
                return sqrt
            case .cubic:
                return { pow($0, 1/3) }
            case .exponential:
                return log
            case .customComplexity(let inverseFunction):
                return inverseFunction
            }
        }
    }

    /// Ranges of values to use for testPoints (values of `n` in `O(f(n))`).
    public struct Scale {
        public static let tiny   = exponentialSeries(size: 10, from: 5,    to: 100)
        public static let small  = exponentialSeries(size: 10, from: 10,   to: 1_000)
        public static let medium = exponentialSeries(size: 10, from: 100,  to: 1_000_000)
        public static let large  = exponentialSeries(size: 10, from: 1000, to: 1_000_000_000)
    }

    private struct Regression {
        public let slope: Double
        public let intercept: Double
        public let correlation: Double
    }

    // MARK: Instance Methods

    /// Benchmarks the performance of a closure.
    public func benchmark <C> (
        mock object: C,
        setupFunction: Setup<C>,
        measuring closure: Run<C>,
        isMutating: Bool,
        testPoints: [Double] = Scale.medium,
        trialCount: Int = 10
    ) -> Benchmark
    {
        return testPoints.map { point in
            var pointMock = object
            setupFunction(&pointMock, point)
            let average = (0..<trialCount).map { _ in
                // if the closure is mutating, create a copy before timing the closure
                if isMutating {
                    var trialMock = pointMock
                    return time(point: point, mock: &trialMock, measuring: closure);
                } else {
                    return time(point: point, mock: &pointMock, measuring: closure);
                }
            }.reduce(0, +) / Double(trialCount)
            return (point, average)
        }
    }

    private func time <C> (
        point: Double,
        mock: inout C,
        measuring closure: Run<C>
    ) -> Double
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        closure(&mock, point)
        let finishTime = CFAbsoluteTimeGetCurrent()
        return finishTime - startTime
    }

    /// Assert that the data indicates that performance is constant-time ( O(1) ).
    public func assertConstantTimePerformance(
        _ data: Benchmark,
        slopeAccuracy: Double = 0.01
    )
    {
        let results = linearRegression(data)

        if Configuration.verbose {
            print("\(#function): data:")
            for (x, y) in data { print("\t(\(x), \(y))") }

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

    /// Performs linear regression on the given dataset.
    private func linearRegression(_ data: Benchmark) -> Regression {

        let xs = data.map { $0.0 }
        let ys = data.map { $0.1 }
        let sumOfXs = xs.reduce(0, +)
        let sumOfYs = ys.reduce(0, +)
        let sumOfXsSquared = xs.map { pow($0, 2) }.reduce(0, +)
        let sumOfXsTimesYs = data.map(*).reduce(0, +)

        let denominator = Double(data.count) * sumOfXsSquared - pow(sumOfXs, 2)
        let interceptNumerator = sumOfYs * sumOfXsSquared - sumOfXs * sumOfXsTimesYs
        let slopeNumerator = Double(data.count) * sumOfXsTimesYs - sumOfXs * sumOfYs

        let intercept = interceptNumerator / denominator
        let slope = slopeNumerator / denominator

        let correlation = calculateCorrelation(data,
           sumOfXs: sumOfXs,
           sumOfYs: sumOfYs,
           slope: slope
        )

        return Regression(slope: slope, intercept: intercept, correlation: correlation)
    }

    /// Helper function to calculate the regression coefficient ("r") of the given dataset.
    private func calculateCorrelation(
        _ data: Benchmark,
        sumOfXs: Double,
        sumOfYs: Double,
        slope: Double
    ) -> Double
    {

        let meanOfYs = sumOfYs / Double(data.count)
        let squaredErrorOfYs = data.map { pow($0.1 - meanOfYs, 2) }.reduce(0, +)
        let denominator = squaredErrorOfYs

        if Configuration.verbose {
            print("\(#function): denominator: \(denominator)")
        }

        guard denominator != 0 else { return 0 }

        let meanOfXs = sumOfXs / Double(data.count)
        let squaredErrorOfXs = data.map { pow($0.0 - meanOfXs, 2) }.reduce(0, +)
        let numerator = squaredErrorOfXs

        if Configuration.verbose {
            print("\(#function): numerator: \(numerator)")
        }

        return sqrt(numerator / denominator) * slope
    }
}

/// Maps data representing performance of a certain complexity so that it
/// can be fit with linear regression. This is done by applying the inverse
/// function of the expected performance function.
extension Array where Array == PerformanceTestCase.Benchmark {
    public func mappedForLinearFit(complexity: PerformanceTestCase.Complexity) -> Array {
        return self.map { ($0, complexity.inverse($1)) }
    }
}

// Creates an array of Doubles in an exponential series.
private func exponentialSeries(size: Int, from start: Double, to end: Double) -> [Double] {
    let base = pow(end - start + 1, 1 / (Double(size)-1))
    return (0..<size).map { pow(base, Double($0)) + start - 1 }.map(round)
}
