//
//  AlgorithmComplexityTests.swift
//  PerformanceTestingTests
//
//  Tests that confirm the complexity of algorithms whose complexity
//  classes haven't been tested elsewhere.
//
//  Created by Brian Heim on 8/25/17.
//

import XCTest
import PerformanceTesting

typealias Matrix<T> = [[T]]

class AlgorithmComplexityTests: XCTestCase {

    // MARK: Quadratic tests.

    // Filling a square matrix should be quadratic in side length
    func testQuadratic_MatrixFill() {
        let benchmark = Benchmark.algorithm(
            testPoints: Scale.small,
            measuring: { _ = makeRandomSquareMatrix(size: $0) }
        )
        XCTAssert(benchmark.performance(is: .quadratic), "\(benchmark)")
    }

    // Adding two square matrices should be quadratic in side length
    func testQuadratic_MatrixAdd() {
        let benchmark = Benchmark.nonMutating(
            testPoints: Scale.small,
            setup: { (makeRandomSquareMatrix(size: $0), makeRandomSquareMatrix(size: $0)) },
            measuring: { (a,b) in _ = squareMatrixAdd(a,b) }
        )
        XCTAssert(benchmark.performance(is: .quadratic), "\(benchmark)")
    }

    // MARK: Cubic.

    func testQuadratic_MatrixMultiply() {
        let benchmark = Benchmark.nonMutating(
            testPoints: Scale.tiny,
            setup: { (makeRandomSquareMatrix(size: $0), makeRandomSquareMatrix(size: $0)) },
            measuring: { (a,b) in _ = squareMatrixMultiply(a,b) }
        )
        XCTAssert(benchmark.performance(is: .cubic), "\(benchmark)")
    }

    // MARK: Exponential: Recursive Fibonacci generator.

    func testExponential_RecursiveFibonacci() {
        // hardcoded; anything larger takes too long, and using `exponentialSeries`
        // generates duplicate test points, which is not a problem, but we like variety
        let benchmark = Benchmark.algorithm(
            testPoints: [5, 8, 11, 14, 17, 20, 23, 26, 30, 35],
            measuring: { _ = fibonacci($0) }
        )
        XCTAssert(benchmark.performance(is: .exponential), "\(benchmark)")
    }

    // MARK: Prime testing

    // primality test should have `big theta sqrt(n)` performance
    func testSquareRoot_Primality() {
        let benchmark = Benchmark.algorithm {
            for number in 0..<10_000 { _ = isPrime($0 + number * 2 + 1) }
        }
        XCTAssert(benchmark.performance(is: .squareRoot), "\(benchmark)")
    }
}

// Constructs a square matrix of random elements
func makeRandomSquareMatrix(size: Int) -> Matrix<Int> {
    var matrix: Matrix<Int> = []
    matrix.reserveCapacity(size)
    for row in 0..<size {
        matrix.append([])
        matrix[row].reserveCapacity(size)
        for _ in 0..<size {
            matrix[row].append(.random(in: 0..<100))
        }
    }
    return matrix
}

// Constructs an all-0 square matrix
func makeZeroMatrix(size: Int) -> Matrix<Int> {
    return Matrix(repeating: [Int](repeating: 0, count: size), count: size)
}

// Adds two square matrices
func squareMatrixAdd(_ first: Matrix<Int>, _ second: Matrix<Int>) -> Matrix<Int> {
    var sum = first
    for row in 0..<second.count {
        for column in 0..<second[row].count {
            sum[row][column] += second[row][column]
        }
    }
    return sum
}

// Multiplies two square matrices
func squareMatrixMultiply(_ first: Matrix<Int>, _ second: Matrix<Int>) -> Matrix<Int> {
    var result = makeZeroMatrix(size: first.count)
    for i in 0..<first.count {
        for j in 0..<first.count {
            for k in 0..<first.count {
                result[i][j] += first[i][k] * second[k][j]
            }
        }
    }
    return result
}

func isPrime(_ number: Int) -> Bool {
    assert(number > 1)
    for factor in 2..<Int(sqrt(Double(number))) {
        if (number % factor == 0) {
            return true
        }
    }
    return false
}

func fibonacci(_ index: Int) -> Int {
    assert(index >= 0)
    guard index > 1 else { return index == 0 ? 0 : 1 }
    return fibonacci(index-1) + fibonacci(index-2)
}
