import XCTest
@testable import Git

class TestHead: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Git.session = Session()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testHEAD() {
        let expect = expectation(description: "")
        Git.create(url) {
            XCTAssertEqual("refs/heads/master", $0.HEAD)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHeadNone() {
        let expect = expectation(description: "")
        Git.create(url) {
            XCTAssertNil($0.head)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTreeNone() {
        let expect = expectation(description: "")
        Git.create(url) {
            XCTAssertNil($0.tree)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLastCommit() {
        let date = Date(timeIntervalSinceNow: -1)
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Git.create(url) { repo in
            Git.session.name = "ab"
            Git.session.email = "cd"
            repo.commit([file], message: "hello world") {
                XCTAssertEqual("ab", repo.head?.author.name)
                XCTAssertEqual("ab", repo.head?.committer.name)
                XCTAssertEqual("cd", repo.head?.author.email)
                XCTAssertEqual("cd", repo.head?.committer.email)
                XCTAssertLessThan(date, repo.head!.author.date)
                XCTAssertLessThan(date, repo.head!.committer.date)
                XCTAssertEqual("hello world\n", repo.head?.message)
                XCTAssertEqual("007a8ffce38213667b95957dc505ef30dac0248d", repo.head?.tree)
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
        Git.create(url) {
            repository = $0
            Git.session.name = "ab"
            Git.session.email = "cd"
            repository.commit([file], message: "hello world") {
                let tree = repository.tree
                XCTAssertEqual(1, tree?.items.count)
                XCTAssertNotNil(tree?.items.first as? Tree.Blob)
                XCTAssertEqual(file, tree?.items.first?.url)
                XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree?.items.first?.id)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
