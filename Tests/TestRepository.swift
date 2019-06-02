import XCTest
@testable import Git

class TestRepository: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testRefresh() {
        let repository = Repository(URL(fileURLWithPath: ""))
        repository.state.last = Date()
        repository.refresh()
        XCTAssertEqual(Date.distantPast, repository.state.last)
    }
    
    func testBranch() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                repository.branch {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertEqual("master", $0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRemoteNone() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                repository.remote {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertEqual("", $0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRemote() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            try? Config("hello world").save(self.url)
            repository.remote {
                XCTAssertEqual(Thread.main, Thread.current)
                XCTAssertEqual("https://hello world", $0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
