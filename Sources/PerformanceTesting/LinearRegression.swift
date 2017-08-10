//
//  LinearRegression.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/10/17.
//

import Darwin

public typealias Benchmark = [(Double, Double)]

internal struct Regression {
    public let slope: Double
    public let intercept: Double
    public let correlation: Double
}

/// Performs linear regression on the given dataset.
internal func linearRegression(_ data: Benchmark) -> Regression {

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

//    if Configuration.verbose {
//        print("\(#function): denominator: \(denominator)")
//    }

    guard denominator != 0 else { return 0 }

    let meanOfXs = sumOfXs / Double(data.count)
    let squaredErrorOfXs = data.map { pow($0.0 - meanOfXs, 2) }.reduce(0, +)
    let numerator = squaredErrorOfXs

//    if Configuration.verbose {
//        print("\(#function): numerator: \(numerator)")
//    }

    return sqrt(numerator / denominator) * slope
}
