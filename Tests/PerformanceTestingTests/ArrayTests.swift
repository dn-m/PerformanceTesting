//
//  ArrayTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class ArrayTests: XCTestCase {

    // MARK: Helper functions.

    // Constructs an array of size `n` with linearly increasing elements.
    func makeArray(size n: Int) -> [Int] {
        return Array(count: n) { $0 }
    }

    // Constructs an array of size `n` with random elements.
    func makeRandomArray(size n: Int) -> [Int] {
        return Array(count: n) { _ in n.random() }
    }

    // MARK: Tests: Inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        assertPerformance(.constant, logging: .detailed) { testPoint in
            let array = makeArray(size: testPoint)
            return meanExecutionTime { _ = array.isEmpty }
        }
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        assertPerformance(.constant) { testPoint in
            let array = makeArray(size: testPoint)
            return meanExecutionTime { _ = array.count }
        }
    }

    // MARK: Tests: Accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscript() {
        assertPerformance(.constant) { testPoint in
            let array = makeArray(size: testPoint)
            return meanExecutionTime { _ = array[3] }
        }
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        assertPerformance(.constant) { testPoint in
            let array = makeArray(size: testPoint)
            return meanExecutionTime { _ = array.first }
        }
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        assertPerformance(.constant) { testPoint in
            let array = makeArray(size: testPoint)
            return meanExecutionTime { _ = array.last }
        }
    }

    // MARK: Tests: adding elements

    // `append` should be (amortized) constant-time in the number of elements
    func testAppend() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var array = makeArray(size: testPoint)
                return time { array.append(6) }
            }
        }
    }

    // `append` should be (amortized) linear-time in the number of appends
    func testAppendAmortized() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                var array: [Int] = []
                return time {
                    for _ in 0..<testPoint { array.append(6) }
                }
            }
        }
    }

    // `insert` should be O(n) in the number of elements
    func testInsert() {
        assertPerformance(.linear, logging: .detailed) { testPoint in
            return meanOutcome {
                var array = makeArray(size: testPoint)
                return time { array.insert(6, at: 0) }
            }
        }
    }

    // MARK: Tests: Removing elements

    // `remove` should be constant-time in the number of elements
    func testRemove() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                var array = makeRandomArray(size: testPoint)
                return time { array.remove(at: 0) }
            }
        }
    }

    // MARK: Tests: Sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                var array = makeRandomArray(size: testPoint)
                return time { array.sort() }
            }
        }
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                var array = makeRandomArray(size: testPoint)
                return time {
                    _ = array.partition { element in element > 50 }
                }
            }
        }
    }
}
