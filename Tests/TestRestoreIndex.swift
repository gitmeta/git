import XCTest
@testable import Git

class TestRestoreIndex: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testAfterReset() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            repository.commit([file], message: "hello world\n") {
                var index = Index(self.url)
                let id = index?.id
                XCTAssertEqual(40, id?.count)
                XCTAssertEqual(1, index?.entries.count)
                XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
                try! FileManager.default.removeItem(at: self.url.appendingPathComponent(".git/index"))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                repository.reset {
                    XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                    index = Index(self.url)
                    XCTAssertEqual(id, index?.id)
                    XCTAssertEqual(1, index?.entries.count)
                    XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterUnpack() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            repository.commit([file], message: "hello world\n") {
                var index = Index(self.url)
                let id = index?.id
                XCTAssertEqual(40, id?.count)
                XCTAssertEqual(1, index?.entries.count)
                XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
                try! FileManager.default.removeItem(at: self.url.appendingPathComponent(".git/index"))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                repository.unpack {
                    XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                    index = Index(self.url)
                    XCTAssertEqual(id, index?.id)
                    XCTAssertEqual(1, index?.entries.count)
                    XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
