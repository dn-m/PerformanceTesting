//
//  Benchmark.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/11/17.
//

public struct Benchmark {
    var data: [(Double,Double)] {
        return tests.map { test in (Double(test.size), test.average) }
    }
    let tests: [PerformanceTest]
}

/// Storage of the size of a structure, and the amounts of time taken to perform each trial.
public struct PerformanceTest {

    public var average: Double {
        return results.average
    }

    // FIXME: Add meta data (structure name, operation name)

    /// The size of the structure over which an operation is performed.
    let size: Int

    /// The amount of time it took to perform each trial.
    let results: [Trial]
}
