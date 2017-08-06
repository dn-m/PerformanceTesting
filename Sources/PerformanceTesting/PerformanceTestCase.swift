//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import Foundation
import XCTest

open class PerformanceTestCase: XCTestCase {

    /// MARK - Associated types.

    public typealias SetupFunction<C> = (inout C, Double) -> ()

    public typealias RunFunction<C> = (inout C, Double) -> ()

    public typealias BenchmarkData = [(Double, Double)]

    public struct Configuration {

        // Controls whether any methods in this file print debugging information
        public static let debug: Bool = true

        // The default minimum correlation to accept
        public static let defaultMinimumCorrelation: Double = 0.95

        // Default number of trials for performance testing
        public static let defaultTrialCount: Int = 10

        // Default accuracy to use when testing the slope of constant-time performance
        public static let defaultConstantTimeSlopeAccuracy: Double = 0.01

        // Default scale to use for test size
        public static let defaultScale: StrideThrough<Double> = Scale.medium
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

        /// Maps data representing performance of a certain complexity so that it
        /// can be fit with linear regression. This is done by applying the inverse
        /// function of the expected performance function.
        public func mapDataForLinearFit(_ data: BenchmarkData) -> BenchmarkData {
            switch self {
            case .constant:
                return data
            case .logarithmic:
                return data.map { ($0.0, exp($0.1)) }
            case .squareRoot:
                return data.map { ($0.0, pow($0.1, 2)) }
            case .linear:
                return data
            case .quadratic:
                return data.map { ($0.0, sqrt($0.1)) }
            case .cubic:
                return data.map { ($0.0, pow($0.1, 1/3)) }
            case .exponential:
                return data.map { ($0.0, log($0.1)) }
            case .customComplexity(let inverseFunction):
                return data.map { ($0.0, inverseFunction($0.1)) }
            }
        }
    }

    /// Ranges of values to use for testPoints (values of `n` in `O(f(n))`).
    public struct Scale {

        public static let tiny   = stride(from: 1.0,         through : 10.0,         by : 1.0)
        public static let small  = stride(from: 1000.0,      through : 10_000.0,     by : 1000.0)
        public static let medium = stride(from: 10_000.0,    through : 100_000.0,    by : 10_000.0)
        public static let large  = stride(from: 1_000_000.0, through : 10_000_000.0, by : 1_000_000.0)

    }

    /// MARK - Public functions.

    /// Benchmarks the performance of a non-mutating operation.
    public func benchmarkNonMutatingOperation <C> (
        mock object: C,
        setupFunction: SetupFunction<C>,
        trialCode: RunFunction<C>,
        testPoints: StrideThrough<Double> = Configuration.defaultScale,
        trialCount: Int = Configuration.defaultTrialCount
    ) -> BenchmarkData
    {
        return testPoints.map { point in
            var pointMock = object
            setupFunction(&pointMock, point)
            let average = (0..<trialCount).map { _ in
                let startTime = CFAbsoluteTimeGetCurrent()
                trialCode(&pointMock, point)
                let finishTime = CFAbsoluteTimeGetCurrent()
                return finishTime - startTime
            }.reduce(0, +) / Double(trialCount)
            return (point, average)
        }
    }

    /// Benchmarks the performance of a mutating operation.
    public func benchmarkMutatingOperation <C> (
        mock object: C,
        setupFunction: SetupFunction<C>,
        trialCode: RunFunction<C>,
        testPoints: StrideThrough<Double> = Configuration.defaultScale,
        trialCount: Int = Configuration.defaultTrialCount
    ) -> BenchmarkData
    {
        return testPoints.map { point in
            var pointMock = object
            setupFunction(&pointMock, point)
            let average = (0..<trialCount).map { _ in
                var trialMock = pointMock
                let startTime = CFAbsoluteTimeGetCurrent()
                trialCode(&trialMock, point)
                let finishTime = CFAbsoluteTimeGetCurrent()
                return finishTime - startTime
            }.reduce(0, +) / Double(trialCount)
            return (point, average)
        }
    }

    /// Assert that the data indicates that performance is constant-time ( O(1) ).
    public func assertConstantTimePerformance(
        _ data: BenchmarkData,
        slopeAccuracy: Double = Configuration.defaultConstantTimeSlopeAccuracy
    )
    {
        let results = linearRegression(data)

        if Configuration.debug {
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
        _ data: BenchmarkData,
        complexity: Complexity,
        minimumCorrelation: Double = Configuration.defaultMinimumCorrelation
    )
    {
        let mappedData = complexity.mapDataForLinearFit(data)
        let results = linearRegression(mappedData)

        if Configuration.debug {
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
            () // do nothing
        }

        XCTAssert(results.correlation >= minimumCorrelation)
    }

    /// MARK - Private associated types

    private struct RegressionData {
        public let slope: Double
        public let intercept: Double
        public let correlation: Double
    }

    /// MARK - Private functions

    /// Performs linear regression on the given dataset.
    private func linearRegression(_ data: BenchmarkData) -> RegressionData {
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
        let correlation = calculateCorrelation(data, sumOfXs: sumOfXs, sumOfYs: sumOfYs, slope: slope)

        return RegressionData(slope: slope, intercept: intercept, correlation: correlation)
    }

    /// Helper function to calculate the regression coefficient ("r") of the given dataset.
    private func calculateCorrelation(
        _ data: BenchmarkData,
        sumOfXs: Double,
        sumOfYs: Double,
        slope: Double
        ) -> Double
    {

        let meanOfYs = sumOfYs / Double(data.count)
        let squaredErrorOfYs = data.map { pow($0.1 - meanOfYs, 2) }.reduce(0, +)
        let denominator = squaredErrorOfYs

        if Configuration.debug {
            print("\(#function): denominator: \(denominator)")
        }

        guard denominator != 0 else { return 0 }

        let meanOfXs = sumOfXs / Double(data.count)
        let squaredErrorOfXs = data.map { pow($0.0 - meanOfXs, 2) }.reduce(0, +)
        let numerator = squaredErrorOfXs

        if Configuration.debug {
            print("\(#function): numerator: \(numerator)")
        }

        return sqrt(numerator / denominator) * slope
    }
}
