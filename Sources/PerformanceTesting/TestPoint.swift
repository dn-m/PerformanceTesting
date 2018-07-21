//
//  TestPoint.swift
//  PerformanceTesting
//
//  Created by James Bean on 7/19/18.
//

/// Collection of trials for a given size of test.
public struct TestPoint {

    // MARK: - Instance Properties

    let size: Int
    let trials: [Double]

    // MARK: - Initializers

    public init(size: Int, trials: [Double]) {
        self.size = size
        self.trials = trials
    }
}
