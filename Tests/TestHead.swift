import XCTest
@testable import Git

class TestHead: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testHEAD() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            XCTAssertEqual("refs/heads/master", try? Hub.head.reference(self.url))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHeadNone() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            XCTAssertNil(try? Hub.head.commit(self.url))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTreeNone() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            XCTAssertNil(try? Hub.head.tree(self.url))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLastCommit() {
        let date = Date(timeIntervalSinceNow: -1)
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "ab"
            Hub.session.email = "cd"
            repository.commit([file], message: "hello world\n") {
                let commit = try? Hub.head.commit(self.url)
                XCTAssertEqual("ab", commit?.author.name)
                XCTAssertEqual("ab", commit?.committer.name)
                XCTAssertEqual("cd", commit?.author.email)
                XCTAssertEqual("cd", commit?.committer.email)
                XCTAssertLessThan(date, commit!.author.date)
                XCTAssertLessThan(date, commit!.committer.date)
                XCTAssertEqual("hello world\n", commit?.message)
                XCTAssertEqual("007a8ffce38213667b95957dc505ef30dac0248d", commit?.tree)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTreeAfterCommit() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "ab"
            Hub.session.email = "cd"
            repository.commit([file], message: "hello world") {
                let tree = try? Hub.head.tree(self.url)
                XCTAssertEqual(1, tree?.items.count)
                XCTAssertEqual(.blob, tree?.items.first?.category)
                XCTAssertEqual(file, tree?.items.first?.url)
                XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree?.items.first?.id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
