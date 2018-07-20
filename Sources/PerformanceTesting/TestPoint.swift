//
//  TestPoint.swift
//  PerformanceTesting
//
//  Created by James Bean on 7/19/18.
//

public struct TestPoint {

    let size: Int
    let trials: [Double]

    // MARK: - Initializers

    public init(size: Int, trials: [Double]) {
        self.size = size
        self.trials = trials
    }
}
