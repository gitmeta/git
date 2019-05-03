import XCTest
@testable import Git

class TestStatus: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        Git.session = Session()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testNoChanges() {
        let expect = expectation(description: "")
        Git.create(url) {
            self.repository = $0
            self.repository.status = {
                XCTAssertTrue($0.isEmpty)
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
            self.repository.statuser.timer.schedule(deadline: .now())
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        Git.create(url) {
            XCTAssertTrue($0.statuser.list.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUntracked() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        Git.create(url) {
            let status = $0.statuser.list
            XCTAssertEqual(1, status.count)
            XCTAssertEqual(.untracked, status.first?.1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAddedWithIndex() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("myfile.txt")
        let file2 = url.appendingPathComponent("myfile2.txt")
        try! Data("hello world".utf8).write(to: file1)
        try! Data("hello world 2".utf8).write(to: file2)
        let index = Index(url) ?? Index()
        Git.create(url) {
            try? $0.add(file1, index: index)
            index.save(self.url)
            let status = $0.statuser.list
            XCTAssertEqual(2, status.count)
            XCTAssertEqual(.untracked, status[1].1)
            XCTAssertEqual(.added, status[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAdded() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let index = Index(url) ?? Index()
        Git.create(url) {
            try? $0.add(file, index: index)
            index.save(self.url)
            let status = $0.statuser.list
            XCTAssertEqual(1, status.count)
            XCTAssertEqual(.added, status.first?.1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testModified() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) {
            self.repository = $0
            Git.session.name = "asd"
            Git.session.email = "my@email.com"
            self.repository.commit([file], message: "First commit") {
                try! Data("modified".utf8).write(to: file)
                let status = self.repository.statuser.list
                XCTAssertEqual(1, status.count)
                XCTAssertEqual(.modified, status.first?.1)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNotEdited() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) {
            self.repository = $0
            Git.session.name = "asd"
            Git.session.email = "my@email.com"
            self.repository.commit([file], message: "First commit") {
                let status = self.repository.statuser.list
                XCTAssertTrue(status.isEmpty)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleted() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) {
            self.repository = $0
            Git.session.name = "asd"
            Git.session.email = "my@email.com"
            self.repository.commit([file], message: "First commit") {
                try! FileManager.default.removeItem(at: file)
                let status = self.repository.statuser.list
                XCTAssertEqual(1, status.count)
                XCTAssertEqual(.deleted, status.first?.1)
                XCTAssertEqual(file, status.first?.0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNotEditedInSubtree() {
        let expect = expectation(description: "")
        let sub = url.appendingPathComponent("sub")
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let file = sub.appendingPathComponent("myfile.txt")
        let outside = url.appendingPathComponent("outside.txt")
        try! Data("hello world\n".utf8).write(to: file)
        try! Data("lorem ipsum\n".utf8).write(to: outside)
        Git.create(url) {
            self.repository = $0
            Git.session.name = "asd"
            Git.session.email = "my@email.com"
            self.repository.commit([outside, file], message: "First commit") {
                XCTAssertTrue(self.repository.statuser.list.isEmpty)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
