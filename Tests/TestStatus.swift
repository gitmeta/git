import XCTest
@testable import Pigit

class TestStatus: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        repository = Repository(url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testNoChanges() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.repository.status {
                XCTAssertTrue($0.untracked.isEmpty)
                XCTAssertTrue($0.added.isEmpty)
                XCTAssertTrue($0.modified.isEmpty)
                XCTAssertTrue($0.deleted.isEmpty)
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUntracked() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        repository.status {
            XCTAssertEqual(1, $0.untracked.count)
            XCTAssertTrue($0.added.isEmpty)
            XCTAssertTrue($0.modified.isEmpty)
            XCTAssertTrue($0.deleted.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
