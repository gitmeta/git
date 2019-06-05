import XCTest
@testable import Git

class TestMerge: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        Hub.session.name = "hello"
        Hub.session.email = "world"
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testMerging() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file1 = self.url.appendingPathComponent("file1.txt")
            try! Data("hello world\n".utf8).write(to: file1)
            repository.commit([file1], message: "First commit.\n") {
                let first = try! Hub.head.id(self.url)
                let file2 = self.url.appendingPathComponent("file2.txt")
                try! Data("lorem ipsum\n".utf8).write(to: file2)
                repository.commit([file2], message: "Second commit.\n") {
                    let second = try! Hub.head.id(self.url)
                    try? repository.stage.merge(first)
                    let merged = try! Hub.head.commit(self.url)
                    XCTAssertEqual(second, merged.parent.first)
                    XCTAssertEqual(first, merged.parent.last)
                    XCTAssertEqual("Merge.\n", merged.message)
                    XCTAssertEqual(3, try? History(self.url).result.count)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
