//
//  TrialTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 7/19/18.
//

import XCTest
@testable import PerformanceTesting

class TrialTests: XCTestCase {
    
    func testTimeInterface() {
        var trial: Trial = NonMutatingTrial(
            subject: (0..<100).map { _ in Int.random(in: 0..<100 ) },
            operation: { array in _ = array.count }
        )
        let _ = trial.time
    }
}
