//
//  SetTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class SetTests: XCTestCase {

    // MARK: Inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let benchmark = Benchmark.nonMutating(setup: set(.increasing)) { _ = $0.isEmpty }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let benchmark = Benchmark.nonMutating(setup: set(.increasing)) { _ = $0.count }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let benchmark = Benchmark.nonMutating(setup: set(.increasing)) { _ = $0.first }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Membership

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsHit() {
        let benchmark = Benchmark.nonMutating(setup: set(.increasing)) {
            _ = $0.contains(Int.random(in: 0..<$0.count))
        }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsMiss() {
        let benchmark = Benchmark.nonMutating(setup: set(.increasing)) { _ = $0.contains($0.count) }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        let benchmark = Benchmark.mutating(setup: set(.increasing)) {
            $0.insert(Int.random(in: 0 ..< $0.count * 2))
        }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let benchmark = Benchmark.mutating(setup: set(.increasing)) { _ = $0.filter { $0 % 5 == 3 } }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is in the set
    func testRemoveHit() {
        let benchmark = Benchmark.mutating(setup: set(.increasing)) {
            $0.remove(Int.random(in: 0..<$0.count))
        }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is not in the set
    func testRemoveMiss() {
        let benchmark = Benchmark.mutating(setup: set(.increasing)) { $0.remove($0.count) }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        let benchmark = Benchmark.mutating(setup: set(.increasing)) { $0.removeFirst() }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // MARK: Combining sets

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a constant-size set, this is constant time.
    func testUnionWithConstantSizedOther() {
        let benchmark = Benchmark.nonMutating(setup: { (Set(0..<$0), Set(0..<100)) }) { (a,b) in
            _ = a.union(b)
        }
        XCTAssert(benchmark.performance(is: .constant), "\(benchmark)")
    }

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a size-n set, this is linear time.
    func testUnionWithLinearSizedOther() {
        let benchmark = Benchmark.nonMutating(setup: { (Set(0..<$0), Set(0..<100)) }) { (a,b) in
            _ = b.union(a)
        }
        XCTAssert(benchmark.performance(is: .linear), "\(benchmark)")
    }
}
