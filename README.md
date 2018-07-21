PerformanceTesting
==================

![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg) [![Build Status](https://travis-ci.org/dn-m/PerformanceTesting.svg?branch=master)](https://travis-ci.org/dn-m/PerformanceTesting)

**PerformanceTesting** is a small, dependency-less Swift 4.0 library that extends `XCTestCase` to
give tools for checking the asymptotic complexity arbitrary algorithms and collections. In other
words, it lets you assert the `log n` in `O(log n)`.

Usage
-----

Include this package by adding the following line to your `Package.swift`'s `dependencies` section:

    .package(url: "https://github.com/dn-m/PerformanceTest", .branch("master"))

Now, you can `import PerformanceTesting` in your test files. The test classes in `./Tests` show
example usage.

<!-- TODO: flesh out this section -->

Development
-----------

### Building

Clone and build this project with:

    git clone https://github.com/dn-m/PerformanceTesting && cd PerformanceTesting
    swift build

### Testing

To run the tests that come with the library:

    swift test

