import XCTest
@testable import Git

class TestContents: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testInitial() {
        let expect = expectation(description: "")
        Git.create(url) {
            self.repository = $0
            XCTAssertTrue(self.repository.needsStatus)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterStatus() {
        let expect = expectation(description: "")
        Git.create(url) {
            _ = $0.statusList
            XCTAssertFalse($0.needsStatus)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterEdition() {
        let expect = expectation(description: "")
        Git.create(url) {
            _ = $0.statusList
            try! "hello\n".write(to: self.url.appendingPathComponent("file.txt"), atomically: true, encoding: .utf8)
            XCTAssertTrue($0.needsStatus)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterContentEdition() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! "hello\n".write(to: file, atomically: true, encoding: .utf8)
        Git.create(url) {
            _ = $0.statusList
            try! "world\n".write(to: file, atomically: true, encoding: .utf8)
            _ = $0.statusList
            try! "lorem ipsum\n".write(to: file, atomically: true, encoding: .utf8)
            XCTAssertTrue($0.needsStatus)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterSubtreeEdition() {
        let expect = expectation(description: "")
        let dir = url.appendingPathComponent("adir")
        try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("file.txt")
        try! "hello\n".write(to: file, atomically: true, encoding: .utf8)
        Git.create(url) {
            _ = $0.statusList
            try! "world\n".write(to: file, atomically: true, encoding: .utf8)
            _ = $0.statusList
            try! "lorem ipsum\n".write(to: file, atomically: true, encoding: .utf8)
            XCTAssertTrue($0.needsStatus)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
