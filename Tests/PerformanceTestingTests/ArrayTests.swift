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

    // Constructs an array of size `n`.
    let constructSizeNArray: SetupFunction<[Int]> = { array, n in
        array.reserveCapacity(Int(n))
        for i in 0..<Int(n) {
            array.append(i)
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

    // `reserveCapacity` should be O(n) in the number of elements
    func testReserveCapacity() {
        let data = benchmarkMutatingOperation(
            mock: [],
            setupFunction: constructSizeNArray,
            trialCode: { array, n in
                for _ in 0..<100 {
                    array.reserveCapacity(Int(n))
                }
            }
        )
        assertPerformanceComplexity(data, complexity: .linear)
    }

}
