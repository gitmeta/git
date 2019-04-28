import XCTest
@testable import Git

class TestList: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        Git.create(url) {
            XCTAssertTrue($0.statusList.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneFile() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data().write(to: file)
        Git.create(url) {
            let status = $0.statusList
            XCTAssertEqual(1, status.count)
            XCTAssertEqual(file, status[0].0)
            expect.fulfill()
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
            let status = $0.statusList
            XCTAssertEqual(2, status.count)
            XCTAssertEqual(file1, status[0].0)
            XCTAssertEqual(file2, status[1].0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneDirectory() {
        let expect = expectation(description: "")
        let directory = url.appendingPathComponent("folder")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Git.create(url) {
            XCTAssertTrue($0.statusList.isEmpty)
            expect.fulfill()
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
            let status = $0.statusList
            XCTAssertEqual(1, status.count)
            XCTAssertEqual(file, status[0].0)
            expect.fulfill()
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
            let status = $0.statusList
            XCTAssertEqual(1, status.count)
            XCTAssertEqual(file, status[0].0)
            expect.fulfill()
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
            let status = $0.statusList
            XCTAssertEqual(2, status.count)
            XCTAssertEqual(file1, status[0].0)
            XCTAssertEqual(file2, status[1].0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSortFiles() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("a")
        let file2 = url.appendingPathComponent("B")
        let file3 = url.appendingPathComponent("c")
        let file4 = url.appendingPathComponent("D")
        let file5 = url.appendingPathComponent("e1")
        let file6 = url.appendingPathComponent("E2")
        let file7 = url.appendingPathComponent("e3")
        let file8 = url.appendingPathComponent("e4e")
        try! Data().write(to: file1)
        try! Data().write(to: file2)
        try! Data().write(to: file3)
        try! Data().write(to: file4)
        try! Data().write(to: file5)
        try! Data().write(to: file6)
        try! Data().write(to: file7)
        try! Data().write(to: file8)
        Git.create(url) {
            let status = $0.statusList
            XCTAssertEqual(file1, status[0].0)
            XCTAssertEqual(file2, status[1].0)
            XCTAssertEqual(file3, status[2].0)
            XCTAssertEqual(file4, status[3].0)
            XCTAssertEqual(file5, status[4].0)
            XCTAssertEqual(file6, status[5].0)
            XCTAssertEqual(file7, status[6].0)
            XCTAssertEqual(file8, status[7].0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSortedInDirectories() {
        let expect = expectation(description: "")
        let directory1 = url.appendingPathComponent("a")
        let directory2 = url.appendingPathComponent("a/d")
        let directory3 = url.appendingPathComponent("b")
        try! FileManager.default.createDirectory(at: directory1, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: directory2, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: directory3, withIntermediateDirectories: true)
        
        let file1 = directory1.appendingPathComponent("a")
        let file2 = directory1.appendingPathComponent("b")
        let file3 = directory1.appendingPathComponent("c")
        let file4 = directory2.appendingPathComponent("a")
        let file5 = directory2.appendingPathComponent("b")
        let file6 = directory2.appendingPathComponent("c")
        let file7 = directory3.appendingPathComponent("a")
        let file8 = directory3.appendingPathComponent("b")
        let file9 = directory3.appendingPathComponent("c")
        try! Data().write(to: file1)
        try! Data().write(to: file2)
        try! Data().write(to: file3)
        try! Data().write(to: file4)
        try! Data().write(to: file5)
        try! Data().write(to: file6)
        try! Data().write(to: file7)
        try! Data().write(to: file8)
        try! Data().write(to: file9)
        Git.create(url) {
            let status = $0.statusList
            XCTAssertEqual(file1, status[0].0)
            XCTAssertEqual(file2, status[1].0)
            XCTAssertEqual(file3, status[2].0)
            XCTAssertEqual(file4, status[3].0)
            XCTAssertEqual(file5, status[4].0)
            XCTAssertEqual(file6, status[5].0)
            XCTAssertEqual(file7, status[6].0)
            XCTAssertEqual(file8, status[7].0)
            XCTAssertEqual(file9, status[8].0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
