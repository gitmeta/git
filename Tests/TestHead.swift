import XCTest
@testable import Git

class TestHead: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testHEAD() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) {
            XCTAssertEqual("refs/heads/master", $0.HEAD)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHeadNone() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) {
            XCTAssertNil($0.head)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLastCommit() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) { repo in
            repo.user.name = "ab"
            repo.user.email = "cd"
            repo.commit([file], message: "hello world") {
                XCTAssertEqual("hello world\n", repo.head?.message)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
