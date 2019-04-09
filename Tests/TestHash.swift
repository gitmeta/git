import XCTest
@testable import Pigit

class TestHash: XCTestCase {
    private var hasher: Hash!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("file.json")
        try! "hello world\n".write(to: url, atomically: true, encoding: .utf8)
        hasher = Hash()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testFile() {
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", try? hasher.file(url))
    }
}
