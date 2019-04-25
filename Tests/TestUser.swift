import XCTest
@testable import Git

class TestUser: XCTestCase {
    func testNonEmpty() {
        XCTAssertThrowsError(try User(String(), email: String()))
        XCTAssertThrowsError(try User(String(), email: "test@mail.com"))
        XCTAssertThrowsError(try User("test", email: String()))
    }
    
    func testCommitCharacters() {
        XCTAssertThrowsError(try User("hello", email: "test<@mail.com"))
        XCTAssertThrowsError(try User("hello", email: "test>@mail.com"))
        XCTAssertThrowsError(try User("h<ello", email: "test@mail.com"))
        XCTAssertThrowsError(try User("h>ello", email: "test@mail.com"))
        XCTAssertThrowsError(try User("hello", email: "test@mail.com\n"))
        XCTAssertThrowsError(try User("hello\n", email: "test@mail.com"))
        XCTAssertThrowsError(try User("hello", email: "test@mail.com\t"))
        XCTAssertThrowsError(try User("hello\t", email: "test@mail.com"))
    }
    
    func testAt() {
        XCTAssertThrowsError(try User("test", email: "testmail.com"))
        XCTAssertThrowsError(try User("test", email: "test@@mail.com"))
    }
    
    func testDot() {
        XCTAssertThrowsError(try User("test", email: "test@mailcom"))
        XCTAssertThrowsError(try User("test", email: "test@mailcom."))
        XCTAssertThrowsError(try User("test", email: "test@.mailcom"))
    }
    
    func testWeird() {
        XCTAssertThrowsError(try User("test", email: "test@ mail.com"))
        XCTAssertThrowsError(try User("test", email: "test @mail.com"))
        XCTAssertThrowsError(try User("test", email: "te st@mail.com"))
        XCTAssertThrowsError(try User("test", email: " test@mail.com"))
        XCTAssertThrowsError(try User("test", email: "test@mail.com "))
    }
}
