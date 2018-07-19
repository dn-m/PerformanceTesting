//
//  TestPointTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 7/19/18.
//

import XCTest
@testable import PerformanceTesting

class TestPointTests: XCTestCase {

    func testMutatingTrialsCount() {
        let testPoint = TestPoint.mutating(
            trialCount: 10,
            size: 0,
            setup: { _ in [0] },
            measuring: { _ in }
        )
        XCTAssertEqual(testPoint.trials.count, 10)
    }

    func testNonMutatingTrialsCount() {
        let testPoint = TestPoint.nonMutating(
            trialCount: 10,
            size: 0,
            setup: { _ in [0] },
            measuring: { _ in }
        )
        XCTAssertEqual(testPoint.trials.count, 10)
    }
}
