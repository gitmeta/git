import XCTest
@testable import Git

class TestHash: XCTestCase {
    private var hasher: Hash!
    private var url: URL!
    private var file: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("file.json")
        try! "hello world\n".write(to: file, atomically: true, encoding: .utf8)
        hasher = Hash()
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testFile() {
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", hasher.file(file).1)
    }
    
    func testTree() {
        XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", hasher.tree(Data()).1)
    }
    
    func testCommit() {
        XCTAssertEqual("dcf5b16e76cce7425d0beaef62d79a7d10fce1f5", hasher.commit("").1)
    }
}
