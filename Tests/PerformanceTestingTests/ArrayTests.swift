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
        assertPerformance(.constant, of: benchmark)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.count }
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Tests: Accessing elements

    // `subscript` should be constant-time in the number of elements
    func testSubscriptGetter() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0[3] }
        assertPerformance(.constant, of: benchmark)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.first }
        assertPerformance(.constant, of: benchmark)
    }

    // `last` should be constant-time in the number of elements
    func testLast() {
        let benchmark = Benchmark.nonMutating(setup: array(.increasing)) { _ = $0.last }
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Adding elements

    // `append` should be (amortized) constant-time in the number of elements.
    func testAppend() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.append(42) }
        assertPerformance(.constant, of: benchmark)
    }

    // `append` should be (amortized) constant-time in the number of appends
    func testAppendAmortized() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.append(6) }
        assertPerformance(.constant, of: benchmark)
    }

    // `insert` should be O(n) in the number of elements
    func testInsert() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.insert(6, at: 0) }
        assertPerformance(.linear, of: benchmark)
    }

    // MARK: Removing elements

    // `remove` should be linear-time in the number of elements.
    func testRemove() {
        let benchmark = Benchmark.mutating(setup: array(.increasing)) { $0.remove(at: 0) }
        assertPerformance(.linear, of: benchmark)
    }

    // MARK: Sorting an array

    // `sort` should be roughly O(n) in the number of elements
    // Technically, it's linearithmic, but we should be able to fit
    // a line to it well enough.
    func testSort() {
        let benchmark = Benchmark.mutating(setup: array(.random)) { $0.sort() }
        assertPerformance(.linear, of: benchmark)
    }

    // `partition` should be O(n) in the number of elements
    func testPartition() {
        let benchmark = Benchmark.mutating(setup: array(.random)) {
            _ = $0.partition { element in element > 50 }
        }
        assertPerformance(.linear, of: benchmark)
    }
}

private func array (_ strategy: FillStrategy) -> (_ size: Int) -> Array<Int> {
    switch strategy {
    case .increasing:
        return { size in .init(0..<size) }
    case .random:
        return { size in .init((0..<size).map { _ in Int.random(in: 0..<size) }) }
    }
}
