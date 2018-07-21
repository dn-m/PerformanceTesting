PerformanceTesting
==================

![Swift](https://img.shields.io/badge/Swift-4.2-brightgreen.svg)
[![Build Status](https://travis-ci.org/dn-m/PerformanceTesting.svg?branch=master)](https://travis-ci.org/dn-m/PerformanceTesting)

**PerformanceTesting** provides tools for checking the [asymptotic complexity](https://en.wikipedia.org/wiki/Asymptotic_computational_complexity) of algorithms and operations over data structures.

For example, this is particularly useful for ensuring that an algorithm that you have written which should be perform in constant time (i.e., ***O(1)***) isn't [accidentally quadratic](https://accidentallyquadratic.tumblr.com/) (i.e., ***O(n<sup>2</sup>)***).

Usage
-----

### `Benchmark`

There are three types of operations which can be tested via static methods on the `Benchmark` structure.

#### `nonMutating`

If the operation that you are testing does not mutate its subject (e.g., `Array.count`), use `Benchmark.nonMutating`:

```Swift
let benchmark = Benchmark.nonMutating(setup: { Array(0..<$0 }) { _ = $0.count }
```

#### `mutating`

If the operation that you are testing mutates its subject (e.g., `Set.insert`), use `Benchmark.mutating`:

```Swift
let benchmark = Benchmark.mutating(setup: { Set(0..<$0) }) { _ = $0.insert(1) }
```

#### `algorithm`

For algorithms that don't act upon data structures (e.g., `fibonacci`, etc.), `Benchmark.algorithm` wipes away the `setup` phase, and forwards the size directly to the `measuring` closure for you.

```Swift
let benchmark = Benchmark.algorithm { _ = fibonacci($0) }
```

### In the Wild

<!--In order to measure the asymptotic performance your data structures and algorithms, there are three -->


We are pretty sure that the performance guarantees documented by the [Stdlib](https://developer.apple.com/documentation/swift/swift_standard_library) are accurate, so we used these as tests for our testing mechanism.

For example, in order to verify that the `count` property of an `Array` is performed in constant time, one can do the following within an `XCTestCase` subclass.

```Swift
func testArrayCountIsConstant() {
	// Create a `Benchmark` for the given operation.
	let benchmark = Benchmark.nonMutating(
	    // For each size, creates an `Array` with elements increasing from zero up to the size
	    setup: { size in Array(0 ..< size) },
	    // Measures `array.count` 10 times by default, averaging out the results
	    measuring: { array in _ = array.count }
	)
	XCTAssert(benchmark.performance(is: .constant))
}
```

With the use of trailing closure syntax and shorthand closure parameter names, the above can be shortened to:

```Swift
let benchmark = Benchmark.nonMutating(setup: { Array(0..<$0) }) { _ = $0.count }
XCTAssert(benchmark.performance(is: .constant))
```

More configuration is possible by specifying `trialCount` (i.e., how many times an operation is performed per test size), and `testPoints` (i.e., the sizes at which the operation is performed), like so:

```Swift
let benchmark = Benchmark.nonMutating(
    trialCount: 1_000,
    testPoints: [1, 10, 100, 1_000, 1_000_000, 1_000_000_000],
    setup: { size in Array(0 ..< size) },
    measuring: { array in _ = array.count }
)
```

The `Scale` namespace offers default `testPoints` (`.tiny`, `.small`, `.medium`, `.large`) that are good for most tests.

See `./Tests` for more example usage.

Installation
------------

Include this package by adding the following line to your `Package.swift`'s `dependencies` section:

    .package(url: "https://github.com/dn-m/PerformanceTest", .branch("master"))

Add `import PerformanceTesting` to the top of your test files, and you are good to go.

Development
-----------

### Building

Clone and build this project with:

    git clone https://github.com/dn-m/PerformanceTesting && cd PerformanceTesting
    swift build

### Testing

To run the tests that come with the library:

    swift test

