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

    // Random number in [0, upperLimit)
    func randomInteger(_ upperLimit: Int = 1000) -> Int {
        return Int(arc4random_uniform(UInt32(upperLimit)))
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

    // `contains` should be constant-time in the number of elements
    func testContains() {
        assertPerformance(.constant) { testPoint in
            let set = constructSet(size: testPoint)
            return measure { _ = set.contains(randomInteger(testPoint*2)) }
        }
    }

    // MARK: Tests: adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        assertPerformance(.constant) { testPoint in
            return measureMutable {
                var set = constructSet(size: testPoint)
                return time {
                    // ensure an accurate reading, too noisy with just one iteration
                    for _ in 0..<100 {
                        set.insert(randomInteger())
                    }
                }
            }
        }
    }

    // MARK: Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        assertPerformance(.linear) { testPoint in
            let set = constructSet(size: testPoint)
            return measure {
                _ = set.filter { $0 % 5 == 3 }
            }
        }
    }

    // `remove` should be constant-time in the number of elements
    func testRemove() {
        assertPerformance(.constant) { testPoint in
            return measureMutable {
                var set = constructSet(size: testPoint)
                return time { set.remove(randomInteger(testPoint*2)) }
            }
        }
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        assertPerformance(.constant) { testPoint in
            return measureMutable {
                var set = constructSet(size: testPoint)
                return time { set.removeFirst() }
            }
        }
    }

    // MARK: Tests: combining sets

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a constant-size set, this is constant time.
    func testUnionWithConstantSizedOther() {
        assertPerformance(.constant) { testPoint in
            return measureMutable {
                let benchSet = constructSet(size: testPoint)
                let otherSet = Set.init(0..<100)
                return time { _ = benchSet.union(otherSet) }
            }
        }
    }

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a size-n set, this is linear time.
    func testUnionWithLinearSizedOther() {
        assertPerformance(.linear) { testPoint in
            return measureMutable {
                let benchSet = constructSet(size: testPoint)
                let otherSet = Set.init(0..<100)
                return time { _ = otherSet.union(benchSet) }
            }
        }
    }

}
