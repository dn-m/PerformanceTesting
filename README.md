[![Build Status](https://travis-ci.org/dn-m/PerformanceTesting.svg?branch=master)](https://travis-ci.org/dn-m/PerformanceTesting)

# PerformanceTesting

**PerformanceTesting** is a small, dependency-less Swift 4.0 library that extends `XCTestCase` to
give tools for checking the asymptotic complexity arbitrary algorithms and collections. In other
words, it lets you assert the `log n` in `O(log n)`.

## Building

PerformanceTesting uses the Swift Package Manager:

    git clone https://github.com/dn-m/PerformanceTesting && cd PerformanceTesting
    swift build

To run the tests that come with the library:

    swift test

Now, you can `import PerformanceTesting` in your test files.

## Usage

The test classes in `./Tests` show example usage.

<!-- TODO: flesh out this section -->
