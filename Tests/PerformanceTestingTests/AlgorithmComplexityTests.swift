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

class AlgorithmComplexityTests: XCTestCase {

    // MARK: Helper functions.

    typealias Matrix<T> = [[T]]

    // Constructs a square matrix of random elements
    func makeRandomSquareMatrix(size: Int) -> Matrix<Int> {
        var matrix: Matrix<Int> = []
        matrix.reserveCapacity(size)
        for row in 0..<size {
            matrix.append([])
            matrix[row].reserveCapacity(size)
            for _ in 0..<size {
                matrix[row].append(100.random())
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

    // MARK: Quadratic tests.

    // Filling a square matrix should be quadratic in side length
    func testQuadratic_MatrixFill() {
        assertPerformance(.quadratic, testPoints: Scale.small) { testPoint in
            meanExecutionTime {
                _ = makeRandomSquareMatrix(size: testPoint)
            }
        }
    }

    // Adding two square matrices should be quadratic in side length
    func testQuadratic_MatrixAdd() {
        assertPerformance(.quadratic, testPoints: Scale.small) { testPoint in
            meanOutcome {
                let first = makeRandomSquareMatrix(size: testPoint)
                let second = makeRandomSquareMatrix(size: testPoint)
                return time { _ = squareMatrixAdd(first, second) }
            }
        }
    }

    // Adding two square matrices should be quadratic in side length
    func testQuadratic_MatrixAddManual() {
        assertPerformance(.quadratic, testPoints: Scale.small) { testPoint in
            meanOutcome {
                let first = makeRandomSquareMatrix(size: testPoint)
                let second = makeRandomSquareMatrix(size: testPoint)
                var sum = makeZeroMatrix(size: testPoint)
                return time {
                    for row in 0..<first.count {
                        for column in 0..<first.count {
                            sum[row][column] = first[row][column] + second[row][column]
                        }
                    }
                }
            }
        }
    }

    // MARK: Cubic tests.

    func testQuadratic_MatrixMultiply() {
        assertPerformance(.cubic, testPoints: Scale.tiny) { testPoint in
            meanOutcome {
                let first = makeRandomSquareMatrix(size: testPoint)
                let second = makeRandomSquareMatrix(size: testPoint)
                return time { _ = squareMatrixMultiply(first, second) }
            }
        }
    }

    // MARK: Exponential tests: recursive Fibonacci generator.

    func fibonacci(_ index: Int) -> Int {
        assert(index >= 0)
        guard index > 1 else { return index == 0 ? 0 : 1 }
        return fibonacci(index-1) + fibonacci(index-2)
    }

    func testExponential_RecursiveFibonacci() {
        // hardcoded; anything larger takes too long, and using `exponentialSeries`
        // generates duplicate test points, which is not a problem, but we like variety
        let testPoints = [5, 8, 11, 14, 17, 20, 23, 26, 30, 35]
        assertPerformance(.exponential, testPoints: testPoints) { testPoint in
            meanExecutionTime { _ = fibonacci(testPoint) }
        }
    }

    // MARK: Square root tests: prime testing

    func isPrime(_ number: Int) -> Bool {
        assert(number > 1)
        for factor in 2..<Int(sqrt(Double(number))) {
            if (number % factor == 0) {
                return true
            }
        }
        return false
    }

    // primality test should have `big theta sqrt(n)` performance
    func testSquareRoot_Primality() {
        assertPerformance(.squareRoot) { testPoint in
            meanExecutionTime {
                // make sure to get enough primes that performance rounds out as expected
                for number in 0..<100 {
                    _ = isPrime(testPoint + number*2 + 1)
                }
            }
        }
    }
}
