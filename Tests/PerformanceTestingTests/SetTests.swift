//
//  SetTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class SetTests: PerformanceTestCase {

    /// MARK - Helper functions.

    // Constructs a set of size `n` with linearly increasing elements.
    let constructSizeNSet: SetupFunction<Set<Int>> = { set, n in
        set.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            set.insert(i)
        }
    }

    /// MARK - Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, _ in _ = set.isEmpty }
        )
        assertConstantTimePerformance(data)
    }

}
