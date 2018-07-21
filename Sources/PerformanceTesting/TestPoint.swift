//
//  TestPoint.swift
//  PerformanceTesting
//
//  Created by James Bean on 7/19/18.
//

/// Collection of trials for a given size of test.
public struct TestPoint {

    // MARK: - Instance Properties

    var average: Double {
        return trials.average
    }

    let size: Int
    let trials: [Double]

    // MARK: - Initializers

    public init(size: Int, trials: [Double]) {
        self.size = size
        self.trials = trials
    }
}

extension TestPoint: CustomStringConvertible {
    public var description: String {
        return """
        Size: \(size) (Average: \(average))
        Times:
            \(trials.map { String($0) }.joined(separator: "\n\t"))
        """
    }
}
