import XCTest
@testable import Git

class TestSession: XCTestCase {
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        UserDefaults.standard.removeObject(forKey: "session")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "session")
    }
    
    func testLoadFromGit() {
        let expect = expectation(description: "")
        XCTAssertTrue(Hub.session.email.isEmpty)
        XCTAssertTrue(Hub.session.name.isEmpty)
        let data = "hasher\n".data(using: .utf8)!
        let url = URL(fileURLWithPath: "hello/world")
        let session = Session()
        session.name = "lorem ipsum"
        session.email = "lorem@world.com"
        session.user = "pablo@mousaka.com"
        session.bookmark = data
        session.url = url
        session.save()
        Hub.session.load {
            XCTAssertEqual("lorem ipsum", Hub.session.name)
            XCTAssertEqual("lorem@world.com", Hub.session.email)
            XCTAssertEqual("pablo@mousaka.com", Hub.session.user)
            XCTAssertEqual(data, Hub.session.bookmark)
            XCTAssertEqual(url.path, Hub.session.url.path)
            XCTAssertEqual(.main, Thread.current)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateName() {
        let expect = expectation(description: "")
        XCTAssertTrue(Hub.session.email.isEmpty)
        XCTAssertTrue(Hub.session.name.isEmpty)
        Hub.session.update("pablo", email: "mousaka@mail.com") {
            Hub.session.name = ""
            Hub.session.email = ""
            Hub.session.load {
                XCTAssertEqual("pablo", Hub.session.name)
                XCTAssertEqual("mousaka@mail.com", Hub.session.email)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateUrl() {
        let expect = expectation(description: "")
        XCTAssertTrue(Hub.session.email.isEmpty)
        XCTAssertTrue(Hub.session.name.isEmpty)
        let data = "hasher\n".data(using: .utf8)!
        let url = URL(fileURLWithPath: "hello/world")
        Hub.session.update(url, bookmark: data) {
            Hub.session.url = URL(fileURLWithPath: "")
            Hub.session.bookmark = Data()
            Hub.session.load {
                XCTAssertEqual(data, Hub.session.bookmark)
                XCTAssertEqual(url.path, Hub.session.url.path)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPurchase() {
        let expect = expectation(description: "")
        XCTAssertTrue(Hub.session.purchase.isEmpty)
        DispatchQueue.global(qos: .background).async {
            Hub.session.purchase("hello.cloud") {
                XCTAssertEqual(.main, Thread.current)
                Hub.session.purchase = []
                Hub.session.load {
                    XCTAssertEqual(.cloud, Hub.session.purchase.first)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPurchaseAgain() {
        let expect = expectation(description: "")
        XCTAssertTrue(Hub.session.purchase.isEmpty)
        Hub.session.purchase("hello.cloud") {
            Hub.session.purchase("hello.cloud") {
                Hub.session.load {
                    XCTAssertEqual(1, Hub.session.purchase.count)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
