//
//  TestPoint.swift
//  PerformanceTesting
//
//  Created by James Bean on 7/19/18.
//

public struct TestPoint {

    // MARK: - Type Methods

    /// - Returns: A `TestPoint` for an `operation` which mutatings the `Subject` prepared by
    /// `setup`. The times measured for this given `operation` are repeated the amount of times of
    /// the given `trialCount`.
    static func mutating <Subject> (
        trialCount: Int,
        size: Int,
        setup: (Int) -> Subject,
        measuring operation: @escaping (inout Subject) -> Void
    ) -> TestPoint
    {
        let trials: [Trial] = (0..<trialCount).map { _ in
            MutatingTrial(subject: setup(size), operation: operation)
        }
        return TestPoint(size: size, trials: trials)
    }

    static func nonMutating <Subject> (
        trialCount: Int,
        size: Int,
        setup: (Int) -> Subject,
        measuring operation: @escaping (Subject) -> Void
    ) -> TestPoint
    {
        let subject = setup(size)
        let trials: [Trial] = (0..<trialCount).map { _ in
            NonMutatingTrial(subject: subject, operation: operation)
        }
        return TestPoint(size: size, trials: trials)
    }

    // MARK: - Instance Properties

    var times: [Double] {
        return trials.map { $0.time }
    }

    var average: Double {
        return times.average
    }

    let size: Int
    let trials: [Trial]

    // MARK: - Initializers

    public init(size: Int, trials: [Trial]) {
        self.size = size
        self.trials = trials
    }
}
