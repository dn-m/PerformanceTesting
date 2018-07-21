//
//  ArrayTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class ArrayTests: XCTestCase {

    // MARK: Inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.isEmpty }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.count }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Tests: Accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscriptGetter() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0[3] }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.first }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.last }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Adding elements

    // `append` should be (amortized) constant-time in the number of elements.
    func testAppend() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.append(42) }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `append` should be (amortized) constant-time in the number of appends
    func testAppendAmortized() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.append(6) }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `insert` should be O(n) in the number of elements
    func testInsert() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.insert(6, at: 0) }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }

    // MARK: Removing elements

    // `remove` should be linear-time in the number of elements.
    func testRemove() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.remove(at: 0) }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }

    // MARK: Sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        let benchmark = Benchmark.mutating(setup: array(.random)) { $0.sort() }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        let benchmark = Benchmark.mutating(setup: array(.random)) {
            _ = $0.partition { element in element > 50 }
        }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }
}
