import XCTest
@testable import Git

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
                XCTAssertTrue($0.isEmpty)
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        var repository: Repository!
        Git.create(url) {
            repository = $0
            repository.status {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUntracked() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        repository.status {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(.untracked, $0.first?.value)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAdded() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        try? repository.add(file)
        repository.status {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(.added, $0.first?.value)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
