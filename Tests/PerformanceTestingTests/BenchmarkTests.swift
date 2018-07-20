//
//  BenchmarkTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 7/19/18.
//

import XCTest
@testable import PerformanceTesting

class BenchmarkTests: XCTestCase {

    func testMutatingTestPointsCount() {
        let expected = 5
        let benchmark = Benchmark.mutating(
            trialCount: 10,
            testPoints: Array(0..<5),
            setup: { _ in [] },
            measuring: { _ in }
        )
        XCTAssertEqual(benchmark.testPoints.count, expected)
    }

    func testNonMutatingTestPointsCount() {
        let expected = 5
        let benchmark = Benchmark.nonMutating(
            trialCount: 10,
            testPoints: Array(0..<5),
            setup: { _ in [] },
            measuring: { _ in }
        )
        XCTAssertEqual(benchmark.testPoints.count, expected)
    }
}
