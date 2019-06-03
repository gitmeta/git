import XCTest
@testable import Git

class TestCheckout: XCTestCase {
    private var url: URL!
    private var file: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testTwoCommits() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([self.file], message: "hello world") {
                let first = try! Hub.head.id(self.url)
                try! Data("lorem ipsum\n".utf8).write(to: self.file)
                repository.commit([self.file], message: "lorem ipsum") {
                    let second = try! Hub.head.id(self.url)
                    XCTAssertNotEqual(first, second)
                    XCTAssertEqual("lorem ipsum\n", String(decoding: try! Data(contentsOf: self.file), as: UTF8.self))
                    DispatchQueue.global(qos: .background).async {
                        repository.check(first) {
                            XCTAssertEqual(Thread.main, Thread.current)
                            XCTAssertEqual("hello world\n", String(decoding: try! Data(contentsOf: self.file), as: UTF8.self))
                            XCTAssertEqual(first, try! Hub.head.id(self.url))
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
