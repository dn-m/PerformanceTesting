//
//  DataSet.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/10/17.
//

import Darwin

/// Collection of (x,y) data points.
struct DataSet {

    struct LinearRegression {
        let slope: Double
        let intercept: Double
        let correlation: Double
    }

    // MARK: - Instance Properties

    /// - Returns: Linear regression of data contained herein.
    var linearRegression: LinearRegression {

        let (xs,ys) = unzip(data)
        let sumOfXs = xs.sum
        let sumOfYs = ys.sum
        let sumOfXsSquared = xs.map { pow($0,2) }.sum
        let sumOfXsTimesYs = data.map(*).sum

        let denominator = Double(data.count) * sumOfXsSquared - pow(sumOfXs, 2)
        let interceptNumerator = sumOfYs * sumOfXsSquared - sumOfXs * sumOfXsTimesYs
        let slopeNumerator = Double(data.count) * sumOfXsTimesYs - sumOfXs * sumOfYs
        let intercept = interceptNumerator / denominator
        let slope = slopeNumerator / denominator

        return LinearRegression(
            slope: slope,
            intercept: intercept,
            correlation: correlation(data, sumOfXs: sumOfXs, sumOfYs: sumOfYs, slope: slope)
        )
    }

    let data: [(Double,Double)]

    // MARK: - Initializers

    init(_ data: [(Double,Double)]) {
        self.data = data
    }

    // MARK: - Instance Methods

    /// Maps data representing performance of a certain complexity so that it
    /// can be fit with linear regression. This is done by applying the inverse
    /// function of the expected performance function.
    func mappedForLinearFit(complexity: Complexity) -> DataSet {
        return DataSet(data.map { ($0, complexity.inverse($1)) })
    }

    /// - Returns: `true` if the curve of this data resembles the given `complexity` curve.
    /// Otherwise, returns `false`.
    func curve(is complexity: Complexity) -> Bool {
        switch complexity {
        case .constant:
            let tolerance = 0.01
            let results = linearRegression
            return (
                approximatelyEqual(results.slope, 0, epsilon: tolerance) ||
                results.correlation < 0.9
            )
        default:
            let minimumCorrelation = 0.9
            let mappedData = mappedForLinearFit(complexity: complexity)
            let results = mappedData.linearRegression
            return results.correlation >= minimumCorrelation
        }
    }
}

extension DataSet: ExpressibleByArrayLiteral {

    // MARK: - ExpressibleByArrayLiteral

    init(arrayLiteral elements: (Double,Double)...) {
        self.data = elements
    }
}

/// Helper function to calculate the regression coefficient ("r") of the given dataset.
private func correlation(
    _ data: [(Double,Double)],
    sumOfXs: Double,
    sumOfYs: Double,
    slope: Double
) -> Double
{
    let meanOfYs = sumOfYs / Double(data.count)
    let squaredErrorOfYs = data.map { pow($0.1 - meanOfYs, 2) }.sum
    let denominator = squaredErrorOfYs
    guard denominator != 0 else { return 0 }
    let meanOfXs = sumOfXs / Double(data.count)
    let squaredErrorOfXs = data.map { pow($0.0 - meanOfXs, 2) }.sum
    let numerator = squaredErrorOfXs
    return sqrt(numerator / denominator) * slope
}

/// - Returns: `true`  if the given values are equal within the given `epsilon`. Otherwise, `false.`
///
/// - Note: This is a naive implementation which does not address extreme floating point situations.
public func approximatelyEqual <F: FloatingPoint> (_ a: F, _ b: F, epsilon: F) -> Bool {
    if a == b { return true }
    return abs(b-a) < epsilon
}

/// - Returns: A tuplet of arrays from an array of tuples.
func unzip <T,U> (_ array: [(T,U)]) -> ([T],[U]) {
    return (array.map { $0.0 }, array.map { $0.1} )
}
