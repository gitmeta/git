import XCTest
@testable import Git

class TestPack: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at:
            url.appendingPathComponent(".git/objects/pack"), withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testIndexNotFound() {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-0", withExtension: "pack")!)).write(
            to: url.appendingPathComponent(".git/objects/pack/pack-hello.pack"))
        XCTAssertThrowsError(try Pack(url, id: "hello"))
    }
    
    func testPackNotFound() {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-0", withExtension: "idx")!)).write(
            to: url.appendingPathComponent(".git/objects/pack/pack-hello.idx"))
        XCTAssertThrowsError(try Pack(url, id: "hello"))
    }
    
    func testLoad() {
        copy("0")
        let pack = try! Pack(url, id: "0")
        XCTAssertEqual(17, pack.entries.count)
        XCTAssertEqual("18d66ecb5629953eee044aea8997ed800b468613", pack.entries.first?.0)
        XCTAssertEqual("2a9e0f4d", pack.entries.first?.1)
        XCTAssertEqual(1185, pack.entries.first?.2)
        XCTAssertEqual("fe3b1fe02314ddad0ff0b5c86c967c87139cbd8b", pack.entries.last?.0)
        XCTAssertEqual("d1bc91b1", pack.entries.last?.1)
        XCTAssertEqual(895, pack.entries.last?.2)
    }
    
    func testLoadAll() {
        copy("0")
        XCTAssertEqual("18d66ecb5629953eee044aea8997ed800b468613", Pack.load(url).first?.entries.first?.0)
    }
    
    private func copy(_ id: String) {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "idx")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "pack")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
    }
}
