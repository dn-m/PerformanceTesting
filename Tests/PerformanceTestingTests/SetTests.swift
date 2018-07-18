//
//  SetTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class SetTests: XCTestCase {

    // MARK: Helper functions.

    // Constructs a set of size `n` with linearly increasing elements.
    func makeSet(size n: Int) -> Set<Int> {
        return Set(count: n) { $0 }
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        assertPerformance(.constant) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime { _ = set.isEmpty }
        }
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        assertPerformance(.constant) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime { _ = set.count }
        }
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        assertPerformance(.constant) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime { _ = set.first }
        }
    }

    // MARK: Tests: membership

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsHit() {
        assertPerformance(.constant) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime { _ = set.contains(testPoint.random()) }
        }
    }

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsMiss() {
        assertPerformance(.constant) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime { _ = set.contains(testPoint+1) }
        }
    }

    // MARK: Tests: adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var set = makeSet(size: testPoint)
                return time {
                    // ensure an accurate reading, too noisy with just one iteration
                    for _ in 0..<100 {
                        set.insert((testPoint*2).random())
                    }
                }
            }
        }
    }

    // MARK: Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        assertPerformance(.linear) { testPoint in
            let set = makeSet(size: testPoint)
            return meanExecutionTime {
                _ = set.filter { $0 % 5 == 3 }
            }
        }
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is in the set
    func testRemoveHit() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var set = makeSet(size: testPoint)
                return time { set.remove(testPoint.random()) }
            }
        }
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is not in the set
    func testRemoveMiss() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var set = makeSet(size: testPoint)
                return time { set.remove(testPoint+1) }
            }
        }
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var set = makeSet(size: testPoint)
                return time { set.removeFirst() }
            }
        }
    }

    // MARK: Tests: combining sets

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a constant-size set, this is constant time.
    func testUnionWithConstantSizedOther() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                let benchSet = makeSet(size: testPoint)
                let otherSet = Set.init(0..<100)
                return time { _ = benchSet.union(otherSet) }
            }
        }
    }

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a size-n set, this is linear time.
    func testUnionWithLinearSizedOther() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                let benchSet = makeSet(size: testPoint)
                let otherSet = Set.init(0..<100)
                return time { _ = otherSet.union(benchSet) }
            }
        }
    }

}
