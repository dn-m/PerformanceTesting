//
//  Benchmark.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/11/17.
//

/// Structure containing one or more tests of a single operation over varying input sizes.
//
// TODO: Add structure name info
// TODO: Add operation info
public struct Benchmark {

    /// Array of two-tuples containing inputSize and average performance time.
    var data: [(Double,Double)] {
        return tests.map { test in (Double(test.inputSize), test.average) }
    }

    /// Results of tests of an operation over a single input size.
    let tests: [Test]
}
