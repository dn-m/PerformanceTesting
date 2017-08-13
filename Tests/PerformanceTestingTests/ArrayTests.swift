//
//  ArrayTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class ArrayTests: PerformanceTestCase {

    // MARK: Helper functions.

    // Constructs an array of size `n` with linearly increasing elements.
    func constructArray(size n: Int) -> [Int] {
        var array: [Int] = []
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            array.append(i)
        }
        return array
    }

    // Constructs an array of size `n` with random elements.
    func constructRandomArray(size n: Int) -> [Int] {
        var array: [Int] = []
        array.reserveCapacity(Int(n))
        for _ in 0..<Int(n) {
            let randomNumber = Int(arc4random_uniform(UInt32(n)))
            array.append(randomNumber)
        }
        return array
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        assertPerformance(.constant) { testPoint in
            let array = constructArray(size: Int(testPoint))
            return measure { _ = array.isEmpty }
        }
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        assertPerformance(.constant) { testPoint in
            let array = constructArray(size: Int(testPoint))
            return measure { _ = array.count }
        }
    }

    // MARK: Tests: accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscript() {
        assertPerformance(.constant) { testPoint in
            let array = constructArray(size: Int(testPoint))
            return measure { _ = array[3] }
        }
    }

/*
    // `first` should be constant-time in the number of elements
    func testFirst() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.first }
        )
        assertConstantTimePerformance(data)
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.last }
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: adding elements

    // `append` should be (amortized) constant-time in the number of elements
    func testAppend() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in array.append(6) }
        )
        assertConstantTimePerformance(data)
    }

    // `insert` should be O(n) in the number of elements
    func testInsert() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in
                for _ in 0..<100 {
                    array.insert(6, at: 0)
                }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

*/

    // MARK: Tests: removing elements


    // `remove` should be constant-time in the number of elements
    func testRemove() {
        assertPerformance(.linear) { testPoint in
            return measureMutable {
                var array = constructRandomArray(size: Int(testPoint))
                return time { array.remove(at: 0) }
            }
        }
    }

    // MARK: Tests: sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        assertPerformance(.linear) { testPoint in
            return measureMutable {
                var array = constructRandomArray(size: Int(testPoint))
                return time { array.sort() }
            }
        }
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        assertPerformance(.linear) { testPoint in
            return measureMutable {
                var array = constructRandomArray(size: Int(testPoint))
                return time {
                    _ = array.partition { element in element > 50 }
                }
            }
        }
    }
}
