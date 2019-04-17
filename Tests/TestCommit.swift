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
        var user = Commit.User()
        user.name = "johnny"
        user.email = "test"
        user.date = Date(timeIntervalSince1970: 1494296655)
        let commit = Commit("hello world", user: user, tree: "lorem ipsum")
        XCTAssertEqual("johnny", commit.author.name)
        XCTAssertEqual("johnny", commit.committer.name)
        XCTAssertEqual("email", commit.author.email)
        XCTAssertEqual("email", commit.committer.email)
        XCTAssertEqual("lorem ipsum", commit.tree)
        XCTAssertEqual("hello world", commit.message)
        XCTAssertGreaterThan(commit.author.date, user.date)
        XCTAssertGreaterThan(commit.committer.date, user.date)
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
