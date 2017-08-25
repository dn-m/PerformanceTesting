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

class AlgorithmComplexityTests: PerformanceTestCase {

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
            meanExecutionTime {
                let first = makeRandomSquareMatrix(size: testPoint)
                let second = makeRandomSquareMatrix(size: testPoint)
                _ = squareMatrixMultiply(first, second)
            }
        }
    }

}
