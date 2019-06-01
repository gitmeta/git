import XCTest
@testable import Git

class TestStaging: XCTestCase {
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
    
    func testIndexSizeNameOneChar() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("a")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file], message: "hello") {
                XCTAssertEqual(96, try! Data(contentsOf: self.url.appendingPathComponent(".git/index")).count)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIndexSizeNameTwoChar() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("ab")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file], message: "hello") {
                XCTAssertEqual(104, try! Data(contentsOf: self.url.appendingPathComponent(".git/index")).count)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIndexSizeNameThreeChar() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("abc")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file], message: "hello") {
                XCTAssertEqual(104, try! Data(contentsOf: self.url.appendingPathComponent(".git/index")).count)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIndexSizeNameTenChar() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("abcdefghij")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file], message: "hello") {
                XCTAssertEqual(112, try! Data(contentsOf: self.url.appendingPathComponent(".git/index")).count)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIndexSubtree() {
        let expect = expectation(description: "")
        let a = url.appendingPathComponent("a")
        let b = a.appendingPathComponent("b")
        let c = a.appendingPathComponent("c")
        try! FileManager.default.createDirectory(at: b, withIntermediateDirectories: true)
        try! FileManager.default.createDirectory(at: c, withIntermediateDirectories: true)
        let file1 = b.appendingPathComponent("myfile1.txt")
        let file2 = c.appendingPathComponent("myfile2.txt")
        try! Data("hello world\n".utf8).write(to: file1)
        try! Data("lorem ipsum\n".utf8).write(to: file2)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file1, file2], message: "hello") {
                let index = Index(self.url)
                XCTAssertEqual(2, index?.entries.count)
                XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
                XCTAssertEqual(file1.path, index?.entries.first?.url.path)
                XCTAssertEqual(12, index?.entries.first?.size)
                XCTAssertEqual("01a59b011a48660bb3828ec72b2b08990b8cf56b", index?.entries.last?.id)
                XCTAssertEqual(file2.path, index?.entries.last?.url.path)
                XCTAssertEqual(12, index?.entries.last?.size)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTreeAfterPartialUpdate() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("file1")
        let file2 = url.appendingPathComponent("file2")
        try! Data("hello world\n".utf8).write(to: file1)
        try! Data("lorem ipsum\n".utf8).write(to: file2)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([file1, file2], message: "hello") {
                try! Data("hello world updated\n".utf8).write(to: file1)
                repository.commit([file1], message: "hello") {
                    XCTAssertEqual(2, (try? Hub.head.tree(self.url))?.items.count)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
