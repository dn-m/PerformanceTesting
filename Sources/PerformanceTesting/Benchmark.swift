//
//  Benchmark.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/11/17.
//

import Foundation

public struct Benchmark <Subject> {

    // MARK: - Type Methods

    public static func mutating <Subject> (
        trialCount: Int = 10,
        testPoints: [Int] = Scale.medium,
        setup: @escaping (Int) -> Subject,
        measuring operation: @escaping (inout Subject) -> Void
    ) -> Benchmark
    {
        var points: [TestPoint] = []
        for size in testPoints {
            var trials: [Double] = []
            for _ in 0..<trialCount {
                var subject = setup(size)
                let time = measure { operation(&subject) }
                trials.append(time)
            }
            points.append(TestPoint(size: size, trials: trials))
        }
        return Benchmark(testPoints: points)
    }

    public static func nonMutating <Subject> (
        trialCount: Int = 10,
        testPoints: [Int] = Scale.medium,
        setup: @escaping (Int) -> Subject,
        measuring operation: @escaping (Subject) -> Void
    ) -> Benchmark
    {
        var points: [TestPoint] = []
        for size in testPoints {
            var trials: [Double] = []
            let subject = setup(size)
            for _ in 0..<trialCount {
                trials.append(measure { operation(subject) })
            }
            points.append(TestPoint(size: size, trials: trials))
        }
        return Benchmark(testPoints: points)
    }

    // MARK: - Instance Properties

    // temp
    var data: [(Double,Double)] {
        return testPoints.map { (Double($0.size), $0.trials.average) }
    }

    let testPoints: [TestPoint]

    // MARK: - Initializers

    init(testPoints: [TestPoint]) {
        self.testPoints = testPoints
    }
}

/// - Returns: The amount of time that it takes to perform the given `operation`.
internal func measure (operation: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    operation()
    let finish = CFAbsoluteTimeGetCurrent()
    return finish - start
}
