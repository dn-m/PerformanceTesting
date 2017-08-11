//
//  SetTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class SetTests: PerformanceTestCase {

    // MARK: Helper functions.

    // Constructs a set of size `n` with linearly increasing elements.
    let constructSizeNSet: Setup<Set<Int>> = { set, n in
        set.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            set.insert(i)
        }
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, _ in _ = set.isEmpty },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, _ in _ = set.count },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, _ in _ = set.first },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: membership

    // `contains` should be constant-time in the number of elements
    func testContains() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                for _ in 0..<100 {
                    _ = set.contains(randomNumber)
                }
            },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                for _ in 0..<10000 {
                    let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                    _ = set.insert(randomNumber)
                }
            },
            isMutating: true
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.filter { $0 % 5 == 3 }
            },
            isMutating: false
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // `remove` should be constant-time in the number of elements
    func testRemove() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                for _ in 0..<10000 {
                    let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                    _ = set.remove(randomNumber)
                }
            },
            isMutating: true
        )
        assertConstantTimePerformance(data)
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.removeFirst()
            },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: combining sets

    // `union` should be linear in the number of elements inserted
    func testUnion() {
        let data = benchmark(
            mock: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.union(Set.init(0..<300))
            },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

}
