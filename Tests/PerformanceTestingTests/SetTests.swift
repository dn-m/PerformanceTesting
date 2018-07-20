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
        let benchmark = Benchmark<Set<Int>>.nonMutating(setup: makeSet, measuring: { _ = $0.isEmpty })
        assertPerformance(.constant, of: benchmark)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let benchmark = Benchmark<Set<Int>>.nonMutating(setup: makeSet, measuring: { _ = $0.count })
        assertPerformance(.constant, of: benchmark)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let benchmark = Benchmark<Set<Int>>.nonMutating(setup: makeSet, measuring: { _ = $0.first })
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Membership

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsHit() {
        let benchmark = Benchmark<Set<Int>>.nonMutating(
            setup: makeSet,
            measuring: { _ = $0.contains(Int.random(in: 0..<$0.count)) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `contains` should be constant-time in the number of elements
    // if the element in question is in the set
    func testContainsMiss() {
        let benchmark = Benchmark<Set<Int>>.nonMutating(
            setup: makeSet,
            measuring: { _ = $0.contains($0.count) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Adding elements

    // `insert` should be constant-time in the number of elements
    func testInsert() {
        let benchmark = Benchmark<Set<Int>>.mutating(
            setup: makeSet,
            measuring: { $0.insert(Int.random(in: 0 ..< $0.count * 2)) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let benchmark = Benchmark<Set<Int>>.mutating(
            setup: makeSet,
            measuring: { _ = $0.filter { $0 % 5 == 3 } }
        )
        assertPerformance(.linear, of: benchmark)
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is in the set
    func testRemoveHit() {
        let benchmark = Benchmark<Set<Int>>.mutating(
            setup: makeSet,
            measuring: { $0.remove(Int.random(in: 0..<$0.count)) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `remove` should be constant-time in the number of elements,
    // if the element to be removed is not in the set
    func testRemoveMiss() {
        let benchmark = Benchmark<Set<Int>>.mutating(
            setup: makeSet,
            measuring: { $0.remove($0.count) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `removeFirst` should be constant-time in the number of elements
    func testRemoveFirst() {
        let benchmark = Benchmark<Set<Int>>.mutating(setup: makeSet, measuring: { $0.removeFirst() })
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Combining sets

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a constant-size set, this is constant time.
    func testUnionWithConstantSizedOther() {
        let benchmark = Benchmark<(Set<Int>,Set<Int>)>.nonMutating(
            setup: { (Set(0..<$0), Set(0..<100)) },
            measuring: { (a,b) in _ = a.union(b) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `union` should be linear in the number of elements inserted
    // Since we are inserting a size-n set, this is linear time.
    func testUnionWithLinearSizedOther() {
        let benchmark = Benchmark<(Set<Int>,Set<Int>)>.nonMutating(
            setup: { (Set(0..<$0), Set(0..<100)) },
            measuring: { (a,b) in _ = b.union(a) }
        )
        assertPerformance(.linear, of: benchmark)
    }
}

// Constructs a set of size `n` with linearly increasing elements.
func makeSet(size n: Int) -> Set<Int> {
    return Set(count: n) { $0 }
}
