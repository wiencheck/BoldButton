import XCTest
@testable import BoldButton

final class BoldButtonTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BoldButton().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
