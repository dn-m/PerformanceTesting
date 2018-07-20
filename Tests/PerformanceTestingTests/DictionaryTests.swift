//
//  DictionaryTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class DictionaryTests: XCTestCase {

    // MARK: Inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.isEmpty }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.count }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Accessing

    // subscript should be constant-time in the number of elements
    func testSubscriptGetter() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0[Int.random(in: 0..<$0.count)] }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `index` should be constant-time in the number of elements
    func testIndex() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.index(forKey: Int.random(in: 0..<$0.count)) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.first }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `keys` should be constant-time in the number of elements
    func testKeys() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.keys }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `values` should be constant-time in the number of elements
    func testValues() {
        let benchmark = Benchmark<[Int:Int]>.nonMutating(
            setup: makeDictionary,
            measuring: { _ = $0.values }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Adding elements

    // `updateValue` should be constant-time in the number of elements
    // in the case that the key exists
    func testUpdateValueHit() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: {
                $0.updateValue(Int.random(in: 0..<$0.count), forKey: Int.random(in: 0..<$0.count))
            }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `updateValue` should be constant-time in the number of elements
    // in the case that the key does not exist
    func testUpdateValueMiss() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: { $0.updateValue($0.count, forKey: $0.count) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: { _ = $0.filter { $0.key % 5 == 3} }
        )
        assertPerformance(.linear, of: benchmark)
    }

    // `removeValue` should be constant-time in the number of elements,
    // if the element to be removed is in the dictionary
    func testRemoveValueHit() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: { $0.removeValue(forKey: Int.random(in: 0..<$0.count)) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `removeValue` should be constant-time in the number of elements,
    // if the element to be removed is not in the dictionary
    func testRemoveValueMiss() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: { $0.removeValue(forKey: $0.count) }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // `removeAll` should be constant-time in the number of elements
    func testRemoveAll() {
        let benchmark = Benchmark<[Int:Int]>.mutating(
            setup: makeDictionary,
            measuring: { $0.removeAll() }
        )
        assertPerformance(.constant, of: benchmark)
    }

    // MARK: Comparing

    // `==` should be linear in the number of elements inserted
    // if the dictionaries are actually equal
    func testEqualityOperator() {
        #warning("Update Benchmark API to handle Dictionary.==")
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                let benchDictionary = makeDictionary(size: testPoint)
                let otherDictionary = makeDictionary(size: testPoint)
                return time { _ = benchDictionary == otherDictionary }
            }
        }
    }

    // `!=` should be linear in the number of elements inserted
    // if the dictionaries are equal
    func testInequalityOperator() {
        #warning("Update Benchmark API to handle Dictionary.!=")
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                let benchDictionary = makeDictionary(size: testPoint)
                let otherDictionary = makeDictionary(size: testPoint)
                return time { _ = benchDictionary != otherDictionary }
            }
        }
    }
}

// Constructs a dictionary of size `n` with linearly increasing elements
// associated with linearly decreasing elements
func makeDictionary(size n: Int) -> Dictionary<Int,Int> {
    return Dictionary(count: n) { (key: $0, value: $0) }
}
