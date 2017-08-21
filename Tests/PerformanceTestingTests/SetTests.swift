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
    func constructSet(size n: Int) -> Set<Int> {
        var set = Set<Int>()
        set.reserveCapacity(n)
        for i in 0..<n {
            set.insert(i)
        }
        return set;
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        assertPerformance(.constant) { testPoint in
            let set = constructSet(size: testPoint)
            return measure { _ = set.isEmpty }
        }
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        assertPerformance(.constant) { testPoint in
            let set = constructSet(size: testPoint)
            return measure { _ = set.count }
        }
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        assertPerformance(.constant) { testPoint in
            let set = constructSet(size: testPoint)
            return measure { _ = set.first }
        }
    }

    // MARK: Tests: membership

/*
    // `contains` should be constant-time in the number of elements
    func testContains() {
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                for _ in 0..<100 {
                    _ = set.contains(randomNumber)
                }
            }
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                for _ in 0..<10000 {
                    let randomNumber = Int(arc4random_uniform(UInt32(n*2)))
                    _ = set.insert(randomNumber)
                }
            }
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.filter { $0 % 5 == 3 }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // `remove` should be constant-time in the number of elements
    func testRemove() {
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
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
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.removeFirst()
            }
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: combining sets

    // `union` should be linear in the number of elements inserted
    func testUnion() {
        let data = benchmark(
            structure: Set.init(),
            setup: constructSizeNSet,
            measuring: { set, n in
                _ = set.union(Set.init(0..<300))
            }
        )
        assertConstantTimePerformance(data)
    }
*/
}
