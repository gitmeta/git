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
    
    func testLoadFromGit() {
        let expect = expectation(description: "")
        XCTAssertTrue(Git.session.email.isEmpty)
        XCTAssertTrue(Git.session.name.isEmpty)
        let data = "hasher\n".data(using: .utf8)!
        let url = URL(fileURLWithPath: "hello/world")
        let session = Session()
        session.name = "lorem ipsum"
        session.email = "lorem@world.com"
        session.bookmark = data
        session.url = url
        session.save()
        Git.session.load {
            XCTAssertEqual("lorem ipsum", Git.session.name)
            XCTAssertEqual("lorem@world.com", Git.session.email)
            XCTAssertEqual(data, Git.session.bookmark)
            XCTAssertEqual(url.path, Git.session.url.path)
            XCTAssertEqual(Thread.main, Thread.current)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateName() {
        let expect = expectation(description: "")
        XCTAssertTrue(Git.session.email.isEmpty)
        XCTAssertTrue(Git.session.name.isEmpty)
        Git.session.update("pablo", email: "mousaka@mail.com") {
            Git.session.name = ""
            Git.session.email = ""
            Git.session.load {
                XCTAssertEqual("pablo", Git.session.name)
                XCTAssertEqual("mousaka@mail.com", Git.session.email)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateUrl() {
        let expect = expectation(description: "")
        XCTAssertTrue(Git.session.email.isEmpty)
        XCTAssertTrue(Git.session.name.isEmpty)
        let data = "hasher\n".data(using: .utf8)!
        let url = URL(fileURLWithPath: "hello/world")
        Git.session.update(url, bookmark: data) {
            Git.session.url = URL(fileURLWithPath: "")
            Git.session.bookmark = Data()
            Git.session.load {
                XCTAssertEqual(data, Git.session.bookmark)
                XCTAssertEqual(url.path, Git.session.url.path)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
