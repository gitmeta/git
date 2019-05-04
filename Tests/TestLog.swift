import XCTest
@testable import Git

class TestLog: XCTestCase {
    private var url: URL!
    private var file: URL!
    private var repository: Repository!
    
    override func setUp() {
        Git.session = Session()
        Git.session.name = "hello"
        Git.session.email = "my@email.com"
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testOneCommit() {
        let expect = expectation(description: "")
        Git.create(url) {
            self.repository = $0
            self.repository.commit([self.file], message: "Lorem ipsum") {
                DispatchQueue.global(qos: .background).async {
                    self.repository.log {
                        XCTAssertEqual(1, $0.count)
                        XCTAssertEqual("hello", $0.first?.author.name)
                        XCTAssertEqual("hello", $0.first?.committer.name)
                        XCTAssertEqual("my@email.com", $0.first?.author.email)
                        XCTAssertEqual("my@email.com", $0.first?.committer.email)
                        XCTAssertEqual("Lorem ipsum\n", $0.first?.message)
                        XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", $0.first?.tree)
                        XCTAssertNil($0.first?.parent)
                        XCTAssertEqual(Thread.main, Thread.current)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoCommits() {
        let expect = expectation(description: "")
        Git.create(url) {
            self.repository = $0
            self.repository.commit([self.file], message: "Lorem ipsum") {
                try! Data("lorem ipsum\n".utf8).write(to: self.file)
                self.repository.commit([self.file], message: "The rebels, the misfits") {
                    self.repository.log {
                        XCTAssertEqual(2, $0.count)
                        XCTAssertEqual("The rebels, the misfits\n", $0.first?.message)
                        XCTAssertEqual("a9b8f695fe7d66da97114df1c3a14df9070d2eae", $0.first?.tree)
                        XCTAssertNotNil($0.first?.parent)
                        XCTAssertEqual("Lorem ipsum\n", $0.last?.message)
                        XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", $0.last?.tree)
                        XCTAssertNil($0.last?.parent)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
