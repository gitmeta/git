import XCTest
@testable import Git

class TestRepack: XCTestCase {
    private var url: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testFailIfInvalidId() {
        XCTAssertThrowsError(try Pack.Maker(url, from: "", to: ""))
        XCTAssertThrowsError(try Pack.Maker(url, from: ""))
    }
    
    func test1Commit() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                if let packed = try? Pack.Maker(self.url, from: Hub.head.id(self.url)).data {
                    let pack = try? Pack(packed)
                    XCTAssertEqual(1, pack?.commits.count)
                    XCTAssertEqual(1, pack?.trees.count)
                    XCTAssertEqual(1, pack?.blobs.count)
                    XCTAssertEqual(try! Hub.head.id(self.url), pack?.commits.keys.first)
                    XCTAssertEqual("92b8b694ffb1675e5975148e1121810081dbdffe", pack?.trees.keys.first)
                    XCTAssertEqual("b15ee8c932e63ad42a744b0c6e1a6c8d20d348ba", pack?.blobs.keys.first)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
