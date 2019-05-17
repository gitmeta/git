import XCTest
@testable import Git

class TestReset: XCTestCase {
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
    
    func testResetOneFile() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
            repository.commit([file], message: "My first commit\n") {
                try! FileManager.default.removeItem(at: file)
                XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
                DispatchQueue.global(qos: .background).async {
                    repository.reset {
                        XCTAssertEqual(Thread.main, Thread.current)
                        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
