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
    let constructSizeNArray: Setup<[Int]> = { array, n in
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            array.append(i)
        }
    }

    // Constructs an array of size `n` with random elements.
    let constructRandomSizeNArray: Setup<[Int]> = { array, n in
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            let randomNumber = Int(arc4random_uniform(UInt32(n)))
            array.append(randomNumber)
        }
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.isEmpty },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.count },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscript() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array[3] },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.first },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in _ = array.last },
            isMutating: false
        )
        assertConstantTimePerformance(data)
    }

    // MARK: Tests: adding elements

    // `append` should be (amortized) constant-time in the number of elements
    func testAppend() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, _ in array.append(6) },
            isMutating: true
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
            },
            isMutating: true
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // MARK: Tests: removing elements

    // `remove` should be O(n) in the number of elements
    func testRemove() {
        let data = benchmark(
            structure: [],
            setup: constructSizeNArray,
            measuring: { array, n in
                for _ in 0..<100 {
                    _ = array.remove(at: 0)
                }
            },
            isMutating: true
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // MARK: Tests: sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        let data = benchmark(
            structure: [],
            setup: constructRandomSizeNArray,
            measuring: { array, n in
                array.sort()
            },
            isMutating: true
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        let data = benchmark(
            structure: [],
            setup: constructRandomSizeNArray,
            measuring: { array, n in
                _ = array.partition { element in element > 50 }
            },
            isMutating: true
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

}
