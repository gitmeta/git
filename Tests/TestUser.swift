import XCTest
@testable import Git

class TestUser: XCTestCase {
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
    }
    
    func testNonEmpty() {
        update("", email: "")
        update("", email: "test@mail.com")
        update("test", email: "")
    }
    
    func testCommitCharacters() {
        update("hello", email: "test<@mail.com")
        update("hello", email: "test>@mail.com")
        update("h<ello", email: "test@mail.com")
        update("h>ello", email: "test@mail.com")
        update("hello", email: "test@mail.com\n")
        update("hello\n", email: "test@mail.com")
        update("hello", email: "test@mail.com\t")
        update("hello\t", email: "test@mail.com")
    }
    
    func testAt() {
        update("test", email: "testmail.com")
        update("test", email: "test@@mail.com")
        update("test", email: "@mail.com")
    }
    
    func testDot() {
        update("test", email: "test@mailcom")
        update("test", email: "test@mailcom.")
        update("test", email: "test@.mailcom")
    }
    
    func testWeird() {
        update("test", email: "test@ mail.com")
        update("test", email: "test @mail.com")
        update("test", email: "te st@mail.com")
        update("test", email: " test@mail.com")
        update("test", email: "test@mail.com ")
    }
    
    private func update(_ user: String, email: String) {
        let expect = expectation(description: "")
        Hub.session.update(user, email: email, error: { _ in
            expect.fulfill()
        }) { XCTFail() }
        waitForExpectations(timeout: 1)
    }
}
