//
//  DictionaryTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
import PerformanceTesting

class DictionaryTests: PerformanceTestCase {

    // MARK: Helper functions.

    // Constructs a dictionary of size `n` with linearly increasing elements
    // associated with linearly decreasing elements
    func makeDictionary(size n: Int) -> Dictionary<Int, Int> {
        return Dictionary(count: n) { (key: $0, value: $0) }
    }

    // MARK: Tests: inspecting

    // `isEmpty` should be constant-time in the number of elements
    func testIsEmpty() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.isEmpty }
        }
    }

    // `count` should be constant-time in the number of elements
    func testCount() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.count }
        }
    }

    // MARK: Tests: accessing

    // subscript should be constant-time in the number of elements
    func testSubscript() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary[testPoint.random()] }
        }
    }

    // `index` should be constant-time in the number of elements
    func testIndex() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.index(forKey: testPoint.random()) }
        }
    }

    // `first` should be constant-time in the number of elements
    func testFirst() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.first }
        }
    }

    // `keys` should be constant-time in the number of elements
    func testKeys() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.keys }
        }
    }

    // `values` should be constant-time in the number of elements
    func testValues() {
        assertPerformance(.constant) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime { _ = dictionary.values }
        }
    }

    // MARK: Tests: adding elements

    // `updateValue` should be constant-time in the number of elements
    // in the case that the key exists
    func testUpdateValueHit() {
        assertPerformance(.constant) { testPoint in

            // ok to mutate here, we're only updating values that exist
            var dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime {
                dictionary.updateValue(testPoint.random(), forKey: testPoint.random())
            }
        }
    }

    // `updateValue` should be constant-time in the number of elements
    // in the case that the key does not exist
    func testUpdateValueMiss() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var dictionary = makeDictionary(size: testPoint)
                return time {
                    let value = testPoint + testPoint.random()
                    let key = testPoint.random()
                    dictionary.updateValue(value, forKey: key)
                }
            }
        }
    }

    // MARK: Tests: removing elements

    // `filter` should be linear in the number of elements
    func testFilter() {
        assertPerformance(.linear) { testPoint in
            let dictionary = makeDictionary(size: testPoint)
            return meanExecutionTime {
                _ = dictionary.filter { $0.key % 5 == 3 }
            }
        }
    }

    // `removeValue` should be constant-time in the number of elements,
    // if the element to be removed is in the dictionary
    func testRemoveValueHit() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var dictionary = makeDictionary(size: testPoint)
                return time { dictionary.removeValue(forKey: testPoint.random()) }
            }
        }
    }

    // `removeValue` should be constant-time in the number of elements,
    // if the element to be removed is not in the dictionary
    func testRemoveValueMiss() {
        assertPerformance(.constant) { testPoint in
            return meanOutcome {
                var dictionary = makeDictionary(size: testPoint)
                return time { dictionary.removeValue(forKey: testPoint+1) }
            }
        }
    }

    // `removeAll` should be constant-time in the number of elements
    func testRemoveAll() {
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                var dictionary = makeDictionary(size: testPoint)
                return time { dictionary.removeAll() }
            }
        }
    }

    // MARK: Tests: comparing

    // `==` should be linear in the number of elements inserted
    // if the dictionaries are actually equal
    func testEqualityOperator() {
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
        assertPerformance(.linear) { testPoint in
            return meanOutcome {
                let benchDictionary = makeDictionary(size: testPoint)
                let otherDictionary = makeDictionary(size: testPoint)
                return time { _ = benchDictionary != otherDictionary }
            }
        }
    }

}
