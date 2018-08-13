import XCTest

extension AlgorithmComplexityTests {
    static let __allTests = [
        ("testExponential_RecursiveFibonacci", testExponential_RecursiveFibonacci),
        ("testQuadratic_MatrixAdd", testQuadratic_MatrixAdd),
        ("testQuadratic_MatrixFill", testQuadratic_MatrixFill),
        ("testQuadratic_MatrixMultiply", testQuadratic_MatrixMultiply),
        ("testSquareRoot_Primality", testSquareRoot_Primality),
    ]
}

extension ArrayTests {
    static let __allTests = [
        ("testAppend", testAppend),
        ("testAppendAmortized", testAppendAmortized),
        ("testCount", testCount),
        ("testFirst", testFirst),
        ("testInsert", testInsert),
        ("testIsEmpty", testIsEmpty),
        ("testLast", testLast),
        ("testPartition", testPartition),
        ("testRemove", testRemove),
        ("testSort", testSort),
        ("testSubscriptGetter", testSubscriptGetter),
    ]
}

extension BenchmarkTests {
    static let __allTests = [
        ("testMutatingTestPointsCount", testMutatingTestPointsCount),
        ("testNonMutatingTestPointsCount", testNonMutatingTestPointsCount),
    ]
}

extension DictionaryTests {
    static let __allTests = [
        ("testCount", testCount),
        ("testEqualityOperator", testEqualityOperator),
        ("testFilter", testFilter),
        ("testFirst", testFirst),
        ("testIndex", testIndex),
        ("testInequalityOperator", testInequalityOperator),
        ("testIsEmpty", testIsEmpty),
        ("testKeys", testKeys),
        ("testRemoveAll", testRemoveAll),
        ("testRemoveValueHit", testRemoveValueHit),
        ("testRemoveValueMiss", testRemoveValueMiss),
        ("testSubscriptGetter", testSubscriptGetter),
        ("testUpdateValueHit", testUpdateValueHit),
        ("testUpdateValueMiss", testUpdateValueMiss),
        ("testValues", testValues),
    ]
}

extension PerformanceTestingTests {
    static let __allTests = [
        ("testConstant", testConstant),
        ("testCubicSlopeOne", testCubicSlopeOne),
        ("testCubicSlopeThree", testCubicSlopeThree),
        ("testExponentialBaseTwoSlopeOne", testExponentialBaseTwoSlopeOne),
        ("testExponentialBaseTwoSlopeThree", testExponentialBaseTwoSlopeThree),
        ("testLinearSlopeOne", testLinearSlopeOne),
        ("testLinearSlopeThree", testLinearSlopeThree),
        ("testLogarithmicBaseESlopeOne", testLogarithmicBaseESlopeOne),
        ("testLogarithmicBaseESlopeThree", testLogarithmicBaseESlopeThree),
        ("testLogarithmicBaseTwoSlopeOne", testLogarithmicBaseTwoSlopeOne),
        ("testLogarithmicBaseTwoSlopeThree", testLogarithmicBaseTwoSlopeThree),
        ("testQuadraticSlopeOne", testQuadraticSlopeOne),
        ("testQuadraticSlopeThree", testQuadraticSlopeThree),
        ("testSquareRootSlopeOne", testSquareRootSlopeOne),
        ("testSquareRootSlopeThree", testSquareRootSlopeThree),
    ]
}

extension SetTests {
    static let __allTests = [
        ("testContainsHit", testContainsHit),
        ("testContainsMiss", testContainsMiss),
        ("testCount", testCount),
        ("testFilter", testFilter),
        ("testFirst", testFirst),
        ("testInsert", testInsert),
        ("testIsEmpty", testIsEmpty),
        ("testRemoveFirst", testRemoveFirst),
        ("testRemoveHit", testRemoveHit),
        ("testRemoveMiss", testRemoveMiss),
        ("testUnionWithConstantSizedOther", testUnionWithConstantSizedOther),
        ("testUnionWithLinearSizedOther", testUnionWithLinearSizedOther),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AlgorithmComplexityTests.__allTests),
        testCase(ArrayTests.__allTests),
        testCase(BenchmarkTests.__allTests),
        testCase(DictionaryTests.__allTests),
        testCase(PerformanceTestingTests.__allTests),
        testCase(SetTests.__allTests),
    ]
}
#endif
