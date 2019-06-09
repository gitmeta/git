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
    
    func test2Commits() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("file1.txt")
        let file2 = url.appendingPathComponent("file2.txt")
        try! Data("hello world\n".utf8).write(to: file1)
        try! Data("lorem ipsum\n".utf8).write(to: file2)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file1], message: "First commit\n") {
                let first = try! Hub.head.id(self.url)
                repository.commit([file2], message: "Second commit\n") {
                    let second = try! Hub.head.id(self.url)
                    if let packed = try? Pack.Maker(self.url, from: second).data {
                        let pack = try? Pack(packed)
                        XCTAssertEqual(2, pack?.commits.count)
                        XCTAssertEqual(2, pack?.trees.count)
                        XCTAssertEqual(2, pack?.blobs.count)
                        XCTAssertNotNil(pack?.commits[first])
                        XCTAssertNotNil(pack?.commits[second])
                        XCTAssertNotNil(pack?.trees["9ba091b521c5e794814b5a5ca78a29727c9cf31f"])
                        XCTAssertNotNil(pack?.trees["82424451ac502bd69712561a524e2d97fd932c69"])
                        XCTAssertNotNil(pack?.blobs["257d6486476026d4fc0136232cac56b0649dedc1"])
                        XCTAssertNotNil(pack?.blobs["b15ee8c932e63ad42a744b0c6e1a6c8d20d348ba"])
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func test2CommitsRestricted() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("file1.txt")
        let file2 = url.appendingPathComponent("file2.txt")
        try! Data("hello world\n".utf8).write(to: file1)
        try! Data("lorem ipsum\n".utf8).write(to: file2)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file1], message: "First commit\n") {
                let first = try! Hub.head.id(self.url)
                repository.commit([file2], message: "Second commit\n") {
                    let second = try! Hub.head.id(self.url)
                    if let packed = try? Pack.Maker(self.url, from: second, to: first).data {
                        let pack = try? Pack(packed)
                        XCTAssertEqual(1, pack?.commits.count)
                        XCTAssertEqual(1, pack?.trees.count)
                        XCTAssertEqual(2, pack?.blobs.count)
                        XCTAssertNotNil(pack?.commits[second])
                        XCTAssertNil(pack?.commits[first])
                        XCTAssertNotNil(pack?.trees["9ba091b521c5e794814b5a5ca78a29727c9cf31f"])
                        XCTAssertNil(pack?.trees["82424451ac502bd69712561a524e2d97fd932c69"])
                        XCTAssertNotNil(pack?.blobs["257d6486476026d4fc0136232cac56b0649dedc1"])
                        XCTAssertNotNil(pack?.blobs["b15ee8c932e63ad42a744b0c6e1a6c8d20d348ba"])
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func test2CommitsToEmpty() {
        let expect = expectation(description: "")
        let file1 = url.appendingPathComponent("file1.txt")
        let file2 = url.appendingPathComponent("file2.txt")
        try! Data("hello world\n".utf8).write(to: file1)
        try! Data("lorem ipsum\n".utf8).write(to: file2)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file1], message: "First commit\n") {
                let first = try! Hub.head.id(self.url)
                repository.commit([file2], message: "Second commit\n") {
                    let second = try! Hub.head.id(self.url)
                    if let packed = try? Pack.Maker(self.url, from: second, to: "").data {
                        let pack = try? Pack(packed)
                        XCTAssertEqual(2, pack?.commits.count)
                        XCTAssertEqual(2, pack?.trees.count)
                        XCTAssertEqual(2, pack?.blobs.count)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
