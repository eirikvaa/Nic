import XCTest
@testable import Nic

final class NicTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Nic().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
