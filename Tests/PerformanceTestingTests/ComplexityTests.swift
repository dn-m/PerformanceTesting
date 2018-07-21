//
//  ComplexityTests.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 8/6/17.
//

import XCTest
@testable import PerformanceTesting

/// Tests to check correctness of PerformanceComplexityAssertion functions.
///
/// - Note: Data is intentionally dirty.
class PerformanceTestingTests: XCTestCase {

    // MARK: Constant

    func testConstant() {
        let data: DataSet = [(1, 1.01), (2, 1.01), (3, 1.05), (4, 0.99)]
        XCTAssert(data.curve(is: .constant), "\(data)")
    }

    // MARK: Logarithmic

    func testLogarithmicBaseTwoSlopeOne() {
        let data: DataSet = [(10, 3.32), (20, 4.32), (30, 4.91), (40, 5.32)]
        XCTAssert(data.curve(is: .logarithmic), "\(data)")
    }

    func testLogarithmicBaseTwoSlopeThree() {
        let data: DataSet = [(10, 4.90), (20, 5.91), (30, 6.49), (40, 6.90)]
        XCTAssert(data.curve(is: .logarithmic), "\(data)")
    }

    func testLogarithmicBaseESlopeOne() {
        let data: DataSet = [(10, 2.30), (20, 2.99), (30, 3.40), (40, 3.69)]
        XCTAssert(data.curve(is: .logarithmic), "\(data)")
    }

    func testLogarithmicBaseESlopeThree() {
        let data: DataSet = [(10, 3.40), (20, 4.09), (30, 4.50), (40, 4.79)]
        XCTAssert(data.curve(is: .logarithmic), "\(data)")
    }

    // MARK: SquareRoot

    func testSquareRootSlopeOne() {
        let data: DataSet = [(10, 3.16), (20, 4.47), (30, 5.47), (40, 6.32)]
        XCTAssert(data.curve(is: .squareRoot), "\(data)")
    }

    func testSquareRootSlopeThree() {
        let data: DataSet = [(10, 9.16), (20, 12.47), (30, 15.47), (40, 18.32)]
        XCTAssert(data.curve(is: .squareRoot), "\(data)")
    }

    // MARK: Linear

    func testLinearSlopeOne() {
        let data: DataSet = [(10, 10), (20, 20.5), (30, 29.5), (40, 39.9)]
        XCTAssert(data.curve(is: .linear), "\(data)")
    }

    func testLinearSlopeThree() {
        let data: DataSet = [(10, 30), (20, 61), (30, 85), (40, 121)]
        XCTAssert(data.curve(is: .linear), "\(data)")
    }

    // MARK: Quadratic

    func testQuadraticSlopeOne() {
        let data: DataSet = [(10, 100), (20, 400), (30, 900), (40, 1640)]
        XCTAssert(data.curve(is: .quadratic), "\(data)")
    }

    func testQuadraticSlopeThree() {
        let data: DataSet = [(10, 300), (20, 1207), (30, 2704), (40, 4805)]
        XCTAssert(data.curve(is: .quadratic), "\(data)")
    }

    // MARK: Cubic

    func testCubicSlopeOne() {
        let data: DataSet = [(10, 1000), (20, 4000), (30, 9000), (40, 16040)]
        XCTAssert(data.curve(is: .cubic), "\(data)")
    }

    func testCubicSlopeThree() {
        let data: DataSet = [(10, 3000), (20, 12007), (30, 27004), (40, 48050)]
        XCTAssert(data.curve(is: .cubic), "\(data)")
    }

    // MARK: Exponential

    func testExponentialBaseTwoSlopeOne() {
        let data: DataSet = [(10, 1024), (20, 1e6), (30, 1e9), (40, 1e12)]
        XCTAssert(data.curve(is: .exponential), "\(data)")
    }

    func testExponentialBaseTwoSlopeThree() {
        let data: DataSet = [(10, 3072), (20, 3e6), (30, 3e9), (40, 3e12)]
        XCTAssert(data.curve(is: .exponential), "\(data)")
    }
}
