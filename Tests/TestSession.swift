import XCTest
@testable import Git

class TestSession: XCTestCase {
    override func setUp() {
        Git.session = Session()
        UserDefaults.standard.removeObject(forKey: "session")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "session")
    }
    
    func testFirstTime() {
        XCTAssertEqual("", Session.load().name)
    }
    
    func testLoadAfterSave() {
        var session = Session()
        session.email = "hello@world.com"
        Session.update(session)
        XCTAssertEqual("hello@world.com", Session.load().email)
    }
    
    func testLoadFromGit() {
        let expect = expectation(description: "")
        XCTAssertTrue(Git.session.email.isEmpty)
        XCTAssertTrue(Git.session.name.isEmpty)
        var session = Session()
        session.name = "lorem ipsum"
        session.email = "lorem@world.com"
        Session.update(session)
        Git.loadSession {
            XCTAssertEqual("lorem ipsum", Git.session.name)
            XCTAssertEqual("lorem@world.com", Git.session.email)
            XCTAssertEqual(Thread.main, Thread.current)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
