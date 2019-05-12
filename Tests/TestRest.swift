import XCTest
@testable import Git

class TestRest: XCTestCase {
    func testEmpty() {
        XCTAssertThrowsError(try Rest().url("", suffix: ""))
    }
    
    func testSuccess() {
        XCTAssertNoThrow(try Rest().url("github.com/some/repository.git", suffix: ""))
    }
    
    func testProtocol() {
        XCTAssertThrowsError(try Rest().url("https://github.com/some/repository.git", suffix: ""))
        XCTAssertThrowsError(try Rest().url("http://github.com/some/repository.git", suffix: ""))
    }
    
    func testEnding() {
        XCTAssertThrowsError(try Rest().url("github.com/some/repository.git/", suffix: ""))
        XCTAssertThrowsError(try Rest().url("github.com/some/repository", suffix: ""))
    }
}
