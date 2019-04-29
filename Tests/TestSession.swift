import XCTest
@testable import Git

class TestSession: XCTestCase {
    func testFirstTime() {
        XCTAssertEqual("", Session.load().name)
    }
    
    func testLoadAfterSave() {
        var session = Session()
        session.email = "hello@world.com"
        Session.update(session)
        XCTAssertEqual("hello@world.com", Session.load().email)
    }
}
