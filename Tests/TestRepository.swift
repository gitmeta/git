import XCTest
@testable import Git

class TestRepository: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
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
        Hub.create(url) {
            XCTAssertEqual("master", $0.branch)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
