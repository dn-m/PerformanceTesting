//
//  PerformanceTestCase.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/6/17.
//

import Foundation
import XCTest

open class PerformanceTestCase: XCTestCase {

    public struct Configuration {

        // Controls whether any methods in this file print debugging information
        public static let debug: Bool = true

        // The default minimum correlation to accept
        public static let defaultMinimumCorrelation: Double = 0.95

        // Default number of trials for performance testing
        public static let defaultTrialCount: Int = 10
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
        public func mapDataForLinearFit(_ data: [(Double, Double)]) -> [(Double, Double)] {
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

    /// Tests the performance of a non-mutating operation.
    public func testNonMutatingOperation <C> (
        mock object: C,
        setupFunction: (inout C, Double) -> (),
        trialCode: (inout C, Double) -> (),
        testPoints: [Double],
        trialCount: Int = Configuration.defaultTrialCount
    ) -> [(Double, Double)]
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

    /// Tests the performance of a mutating operation.
    public func testMutatingOperation <C> (
        mock object: C,
        setupFunction: (inout C, Double) -> (),
        trialCode: (inout C, Double) -> (),
        testPoints: [Double],
        trialCount: Int = Configuration.defaultTrialCount
    ) -> [(Double, Double)]
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

    /// Assert that the data indicates that performance fits well to the given
    /// complexity class. Optional parameter for minimum acceptable correlation.
    public func assertPerformanceComplexity(
        _ data: [(Double, Double)],
        complexity: Complexity,
        minimumCorrelation: Double = Configuration.defaultMinimumCorrelation
    )
    {
        let mappedData = complexity.mapDataForLinearFit(data)
        let (slope, intercept, correlation) = linearRegression(mappedData)

        if Configuration.debug {
            print("\(#function): mapped data:")
            for (x, y) in mappedData { print("\t(\(x), \(y))") }

            print("\(#function): slope:       \(slope)")
            print("\(#function): intercept:   \(intercept)")
            print("\(#function): correlation: \(correlation)")
            print("\(#function): min corr.:   \(minimumCorrelation)")
        }

        // FIXME: should split into two methods, add accuracy arg
        switch complexity {
        case .constant:
            XCTAssertEqual(slope, 0, accuracy: 0.01)
        default:
            XCTAssert(correlation >= minimumCorrelation)
        }
    }

    /// Performs linear regression on the given dataset. Returns a triple of
    /// (slope, intercept, correlation).
    private func linearRegression(_ data: [(Double, Double)]) -> (Double, Double, Double) {
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
        let regressionCoefficient = calculateRegressionCoefficient(data, sumOfXs: sumOfXs, sumOfYs: sumOfYs, slope: slope)

        return (slope, intercept, regressionCoefficient)
    }

    /// Helper function to calculate the regression coefficient ("r") of the given dataset.
    private func calculateRegressionCoefficient(
        _ data: [(Double, Double)],
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
