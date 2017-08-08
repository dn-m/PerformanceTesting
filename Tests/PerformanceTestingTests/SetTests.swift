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

    // `count` should be constant-time in the number of elements
    func testCount() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, _ in _ = set.count }
        )
        assertConstantTimePerformance(data)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, _ in _ = set.first }
        )
        assertConstantTimePerformance(data)
    }

    /// MARK - Tests: membership

    // `contains` should be constant-time in the number of elements
    func testContains() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, n in
                let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                for _ in 0..<100 {
                    _ = set.contains(randomNumber)
                }
            }
        )
        assertConstantTimePerformance(data)
    }

    /// MARK - Tests: adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        let data = benchmarkMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, n in
                for _ in 0..<10000 {
                    let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                    _ = set.insert(randomNumber)
                }
            }
        )
        assertConstantTimePerformance(data)
    }

    /// MARK - Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, n in
                _ = set.filter { $0 % 5 == 3 }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // `remove` should be constant-time in the number of elements
    func testRemove() {
        let data = benchmarkMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, n in
                for _ in 0..<10000 {
                    let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                    _ = set.remove(randomNumber)
                }
            }
        )
        assertConstantTimePerformance(data)
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        let data = benchmarkNonMutatingOperation(
            mock: Set.init(),
            setupFunction: constructSizeNSet,
            trialCode: { set, n in
                _ = set.removeFirst()
            }
        )
        assertConstantTimePerformance(data)
    }

}
