import XCTest
@testable import Git

class TestClone: XCTestCase {
    private var url: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testFail() {
        let expect = expectation(description: "")
        rest._error = Failure.Request.invalid
        DispatchQueue.global(qos: .background).async {
            Hub.clone("", local: self.url, error: { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailOnDownload() {
        var adv = Fetch()
        adv.refs.append("")
        let expect = expectation(description: "")
        rest._error = Failure.Request.invalid
        rest._adv = adv
        DispatchQueue.global(qos: .background).async {
            Hub.clone("", local: self.url, error: { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfRepository() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            Hub.clone("", local: self.url, error: { _ in expect.fulfill() })
        }
        waitForExpectations(timeout: 1)
    }
    
//    func testCreatesFolder() {
//        let expect = expectation(description: "")
//        Hub.create(url) { _ in
//            Hub.clone("", local: self.url, error: { _ in expect.fulfill() })
//        }
//        waitForExpectations(timeout: 1)
//    }
}
