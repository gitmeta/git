import XCTest
@testable import Git

class TestDiff: XCTestCase {
    private var url: URL!
    private var repository: Repository!
    
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
    
    func testOneChange() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            self.repository.commit([file], message: "My first commit\n") {
                try! Data("Lorem ipsum\n".utf8).write(to: file)
                self.repository.diff(file, error: { _ in }) {
                    XCTAssertEqual(2, $0.count)
                    XCTAssertEqual("Lorem ipsum\n", $0.first?.1)
                    XCTAssertEqual("hello world\n", $0.last?.1)
                    XCTAssertGreaterThanOrEqual($0.first!.0, $0.last!.0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
