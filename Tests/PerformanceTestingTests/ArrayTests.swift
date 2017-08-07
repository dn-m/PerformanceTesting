//
//  ArrayTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class ArrayTests: PerformanceTestCase {

    /// MARK - Helper functions.

    // Constructs an array of size `n` with linearly increasing elements.
    let constructSizeNArray: SetupFunction<[Int]> = { array, n in
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            array.append(i)
        }
    }

    // Constructs an array of size `n` with random elements.
    let constructRandomSizeNArray: SetupFunction<[Int]> = { array, n in
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            let randomNumber = Int(arc4random_uniform(UInt32(n)))
            array.append(randomNumber)
        }
    }

    /// MARK - Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let data = benchmarkNonMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in _ = array.isEmpty }
        )
        assertConstantTimePerformance(data)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let data = benchmarkNonMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in _ = array.count }
        )
        assertConstantTimePerformance(data)
    }

    /// MARK - Tests: accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscript() {
        let data = benchmarkNonMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in _ = array[3] }
        )
        assertConstantTimePerformance(data)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let data = benchmarkNonMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in _ = array.first }
        )
        assertConstantTimePerformance(data)
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        let data = benchmarkNonMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in _ = array.last }
        )
        assertConstantTimePerformance(data)
    }

    /// MARK - Tests: adding elements

    // `append` should be (amortized) constant-time in the number of elements
    func testAppend() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in array.append(6) }
        )
        assertConstantTimePerformance(data)
    }

    // `insert` should be O(n) in the number of elements
    func testInsert() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, _ in
                for _ in 0..<100 {
                    array.insert(6, at: 0)
                }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    /// MARK - Tests: removing elements

    // `remove` should be O(n) in the number of elements
    func testRemove() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, n in
                for _ in 0..<2 {
                    _ = array.remove(at: 0)
                }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    /// MARK - Tests: sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructRandomSizeNArray,
            trialCode: { array, n in
                array.sort()
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructRandomSizeNArray,
            trialCode: { array, n in
                _ = array.partition { element in element > 50 }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

}
