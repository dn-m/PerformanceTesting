//
//  Benchmark.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/11/17.
//

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
            var trials: [Trial] = []
            for _ in 0..<trialCount {
                var subject = setup(size)
                let time = measure { operation(&subject) }
                trials.append(TimeTrial(time: time))
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
        return Benchmark(
            testPoints: testPoints.map { size in
                TestPoint.nonMutating(
                    trialCount: trialCount,
                    size: size,
                    setup: setup,
                    measuring: operation
                )
            }
        )
    }

    // MARK: - Instance Properties

    // temp
    var data: [(Double,Double)] {
        return testPoints.map { (Double($0.size), $0.average) }
    }

    let testPoints: [TestPoint]

    // MARK: - Initializers

    init(testPoints: [TestPoint]) {
        self.testPoints = testPoints
    }
}
