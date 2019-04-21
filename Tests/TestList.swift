import XCTest
@testable import Git

class TestList: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneFile() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data().write(to: file)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertEqual(1, $0.count)
                XCTAssertNotNil($0[file])
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoFiles() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("myfile1.txt")
        let file2 = url.appendingPathComponent("myfile2.txt")
        try! Data().write(to: file1)
        try! Data().write(to: file2)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertEqual(2, $0.count)
                XCTAssertNotNil($0[file1])
                XCTAssertNotNil($0[file2])
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneDirectory() {
        let expect = expectation(description: "")
        let directory = url.appendingPathComponent("folder")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneFileInDirectory() {
        let expect = expectation(description: "")
        let directory = url.appendingPathComponent("folder")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file = directory.appendingPathComponent("myfile.txt")
        try! Data().write(to: file)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertEqual(1, $0.count)
                XCTAssertNotNil($0[file])
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneFileInSubDirectory() {
        let expect = expectation(description: "")
        let directory = url.appendingPathComponent("folder")
        let sub = directory.appendingPathComponent("sub")
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let file = sub.appendingPathComponent("myfile.txt")
        try! Data().write(to: file)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertEqual(1, $0.count)
                XCTAssertNotNil($0[file])
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneFileAndFileInDirectory() {
        let expect = expectation(description: "")
        let directory = url.appendingPathComponent("folder")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let file1 = directory.appendingPathComponent("myfile1.txt")
        let file2 = url.appendingPathComponent("myfile2.txt")
        try! Data().write(to: file1)
        try! Data().write(to: file2)
        Git.create(url) {
            self.repository = $0
            self.repository.status {
                XCTAssertEqual(2, $0.count)
                XCTAssertNotNil($0[file1])
                XCTAssertNotNil($0[file2])
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
