//
//  Test.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/11/17.
//

/// Representation of a test of a single operation over a given `inputSize`. This test may have been
/// run multiple times, the measurements of which are stored in `results`.
public struct Test {

    /// Average amount of time to complete a given operation of the `inputSize`.
    public var average: Double {
        return results.average
    }

    /// The size of the input over which an operation is performed.
    let inputSize: Int

    /// The amount of time it took to perform each trial.
    let results: [Double]
}
