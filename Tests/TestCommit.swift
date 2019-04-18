import XCTest
@testable import Git

class TestCommit: XCTestCase {
    private var url: URL!
    private var file: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testCreate() {
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = TimeZone(identifier: "America/Chicago")!
        commit.committer = commit.author
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
        XCTAssertEqual("""
tree 0d21e2f7f760f77ead2cb85cc128efb13f56401d
parent dc0d3343fa24e912f08bc18aaa6f664a4a020079
author Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500
committer Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500

Add project files.

""", commit.serial)
    }
    
    func testSave() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = TimeZone(identifier: "America/Chicago")!
        commit.committer = commit.author
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
        Git.create(url) { _ in
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", commit.save(url))
            let object = try? Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/51/92391e9f907eeb47aa38d1c6a3a4ea78e33564"))
            XCTAssertNotNil(object)
            XCTAssertEqual(55, object?.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptyList() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        repository.user.name = "hello"
        repository.user.email = "world"
        DispatchQueue.global(qos: .background).async {
            repository.commit([], message: "hello world", error: { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptyMessage() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        repository.user.name = "hello"
        repository.user.email = "world"
        repository.commit([file], message: "", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testNoCredentials() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        repository.commit([file], message: "hello world", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testFirstCommit() {
        let expect = expectation(description: "")
        Git.create(url) { repository in
            DispatchQueue.global(qos: .background).async {
                repository.user.name = "hello"
                repository.user.email = "world"
                repository.commit([self.file], message: "hello world") {
                    XCTAssertEqual(Thread.main, Thread.current)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
