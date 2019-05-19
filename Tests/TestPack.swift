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
        XCTAssertThrowsError(try Pack.Index(url, id: "hello"))
    }
    
    func testPackNotFound() {
        XCTAssertThrowsError(try Pack(url, id: "hello"))
    }
    
    func testLoadIndex0() {
        copy("0")
        let pack = try! Pack.Index(url, id: "0")
        XCTAssertEqual(17, pack.entries.count)
        XCTAssertEqual("18d66ecb5629953eee044aea8997ed800b468613", pack.entries.first?.id)
        XCTAssertEqual("2a9e0f4d", pack.entries.first?.crc)
        XCTAssertEqual(1185, pack.entries.first?.offset)
        XCTAssertEqual("fe3b1fe02314ddad0ff0b5c86c967c87139cbd8b", pack.entries.last?.id)
        XCTAssertEqual("d1bc91b1", pack.entries.last?.crc)
        XCTAssertEqual(895, pack.entries.last?.offset)
    }
    
    func testLoadIndex1() {
        copy("1")
        let pack = try! Pack.Index(url, id: "1")
        XCTAssertEqual(14, pack.entries.count)
        XCTAssertEqual("335a33ae387dc24f057852fdb92e5abc71bf6b85", pack.entries.first?.id)
        XCTAssertEqual("54524f1a", pack.entries.first?.crc)
        XCTAssertEqual(12, pack.entries.first?.offset)
    }
    
    func testLoadAllIndex() {
        copy("0")
        copy("1")
        let packs = Pack.load(url)
        XCTAssertEqual("335a33ae387dc24f057852fdb92e5abc71bf6b85", packs.first?.entries.first?.id)
        XCTAssertEqual("18d66ecb5629953eee044aea8997ed800b468613", packs.last?.entries.first?.id)
    }
    
    func testUnpackWithIndex() {
        copy("1")
        let pack = try! Pack.Index(url, id: "1")
    }
    
    func testLoadPack() {
        copy("0")
        let pack = try! Pack(url, id: "0")
        XCTAssertEqual(3, pack.commits.count)
        XCTAssertEqual(8, pack.trees.count)
        XCTAssertEqual(4, pack.blobs.count)
    }
    
    func testLoadFetch0() {
        let pack = try! Pack(Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "fetch0", withExtension: nil)!))
        XCTAssertEqual(1, pack.commits.count)
        XCTAssertEqual(1, pack.trees.count)
        XCTAssertEqual(1, pack.blobs.count)
        XCTAssertEqual("""
tree 9b8166fc80d0f0fe9192d4bf1dbaa87f194e012f\nauthor vauxhall <zero.griffin@gmail.com> 1557649511 +0200\ncommitter GitHub <noreply@github.com> 1557649511 +0200\ngpgsig -----BEGIN PGP SIGNATURE-----\n \n wsBcBAABCAAQBQJc19hnCRBK7hj4Ov3rIwAAdHIIAAPh6Gw1sQOwGSQsX94V8slE\n /5LdUSOjyqb6kkSKFYNJO7HKiBhS5DnLCtytbbbhMCI+VkvD91fwwu75cTzidl/7\n ky4aH+l4O7/rYol3sMXlslrz3uxbMNano8oCXPCmkRd6SDITNPtcLVn1m/1msgo6\n w9/3GrILm7jJBoqsq1Yw9HgPqbk7rEvUmexf7Fn9lb/YYhuisp86XCtDGfqMMRow\n GeXUxGUGlAluDFDDwneTb0PPowHhQioTKOqooaM9ocEDENtzv4EZY4o4lccTegHm\n a69zNgV4ALzMxVpwN03216fS9kw7gRriy9hNGMJIGnVGKIgQD/4B9hZ8Xv9bM84=\n =HKXb\n -----END PGP SIGNATURE-----\n \n\nInitial commit
""", pack.commits.first?.value.0.serial)
        XCTAssertEqual("""
/Users/vaux/Library/Developer/Xcode/DerivedData/Git-awoihalzruiqfzedtwsjcjiszgba/Build/Products/Debug/README.md
""", pack.trees.first?.value.0.items.first?.url.path)
        XCTAssertEqual("""
# test
Test

""", String(decoding: pack.blobs.first!.value, as: UTF8.self))
    }
    
    func testLoadFetch1() {
        let pack = try! Pack(Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "fetch1", withExtension: nil)!))
        XCTAssertEqual(23, pack.commits.count)
        XCTAssertEqual(43, pack.trees.count)
        XCTAssertEqual(23, pack.blobs.count)
    }
    
    private func copy(_ id: String) {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "idx")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "pack")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
    }
    
    private func fetch(_ id: String) {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "pack")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
    }
}
