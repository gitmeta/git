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
        XCTAssertEqual(1185, pack.entries.first?.offset)
        XCTAssertEqual("fe3b1fe02314ddad0ff0b5c86c967c87139cbd8b", pack.entries.last?.id)
        XCTAssertEqual(895, pack.entries.last?.offset)
    }
    
    func testLoadIndex1() {
        copy("1")
        let pack = try! Pack.Index(url, id: "1")
        XCTAssertEqual(14, pack.entries.count)
        XCTAssertEqual("335a33ae387dc24f057852fdb92e5abc71bf6b85", pack.entries.first?.id)
        XCTAssertEqual(12, pack.entries.first?.offset)
    }
    
    func testLoadAllIndex() {
        copy("0")
        copy("1")
        let packs = Pack.load(url)
        XCTAssertEqual("335a33ae387dc24f057852fdb92e5abc71bf6b85", packs.first?.entries.first?.id)
        XCTAssertEqual("18d66ecb5629953eee044aea8997ed800b468613", packs.last?.entries.first?.id)
    }
    
    func testUnpackWithPack() {
        copy("1")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.idx").path))
        let pack = try? Pack(url, id: "1")
        try? pack?.unpack(url)
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/33/5a33ae387dc24f057852fdb92e5abc71bf6b85").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/de/bc85c20f099d7d379d0bbcf3f49643057130ba").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/d4/ad833626ea79708a91e61c461b1c4ed8c5a9a7").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/d2/7de8c22fb0cfdc7d12f8eaf30bcc5343e7f70a").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/8d/c0abf0a0b0d70a0a8680daa69a7df74acfce95").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/7e/6a00e39a6bf673236a1a9dfe10fb84c8cde5e4").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/3e/df2d51b40d48afd71e415bb3df7429d0043909").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/fd/3a92df1d71c4cc25f1d0781977031d3908722d").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/53/93c4bf55b2adf4db6ff8c59b6172b015df2f75").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/50/d65cf62b3d1d7a06d4766693d293ada11f3e8a").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/ce/013625030ba8dba906f756967f9e9ca394464a").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/d3/42d27d93c4e0baac81f2d10f40c10b37ec553b").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/91/77be007bb25b1f12ecc3fd14eb191cd07d69f4").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/6e/d198640569dee5fc505808548729ef230d6a33").path))
    }
    
    func testRemove() {
        copy("1")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.idx").path))
        let pack = try? Pack(url, id: "1")
        try? pack?.remove(url, id: "1")
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.idx").path))
    }
    
    func testLoadPack0() {
        copy("0")
        let pack = try? Pack(url, id: "0")
        XCTAssertEqual(3, pack?.commits.count)
        XCTAssertEqual(10, pack?.trees.count)
        XCTAssertEqual(4, pack?.blobs.count)
    }
    
    func testLoadPack1() {
        copy("1")
        let pack = try! Pack(url, id: "1")
        XCTAssertEqual(5, pack.commits.count)
        XCTAssertEqual(5, pack.trees.count)
        XCTAssertEqual(4, pack.blobs.count)
    }
    
    func testHashTreePack1() {
        copy("1")
        let pack = try! Pack(url, id: "1")
        let tree = pack.trees.first(where: { $0.key == "50d65cf62b3d1d7a06d4766693d293ada11f3e8a" })!.value.0
        XCTAssertEqual("50d65cf62b3d1d7a06d4766693d293ada11f3e8a", Hub.hash.tree(tree.serial).1)
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

""", String(decoding: pack.blobs.first!.value.1, as: UTF8.self))
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
