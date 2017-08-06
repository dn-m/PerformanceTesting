import XCTest
@testable import PerformanceTesting

class PerformanceTestingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PerformanceTesting().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
