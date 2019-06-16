import XCTest
@testable import Git

class TestPack: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/objects/pack"), withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testPackNotFound() {
        XCTAssertThrowsError(try Pack(url, id: "hello"))
    }
    
    func testLoadAllPacks() {
        copy("0")
        copy("1")
        copy("2")
        XCTAssertEqual(3, (try? Pack.pack(url))?.count)
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
    
    func testUnpackSize() {
        copy("1")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-1.idx").path))
        let pack = try? Pack(url, id: "1")
        try? pack?.unpack(url)
        
        XCTAssertEqual(33, (try? Data(contentsOf: url.appendingPathComponent(".git/objects/7e/6a00e39a6bf673236a1a9dfe10fb84c8cde5e4")).count))
        XCTAssertEqual(222, (try? Data(contentsOf: url.appendingPathComponent(".git/objects/33/5a33ae387dc24f057852fdb92e5abc71bf6b85")).count))
        XCTAssertEqual(122, (try? Data(contentsOf: url.appendingPathComponent(".git/objects/53/93c4bf55b2adf4db6ff8c59b6172b015df2f75")).count))
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
        pack?.trees.forEach {
            XCTAssertEqual($0.key, Hub.hash.tree($0.value.0.serial).1)
        }
    }
    
    func testLoadPack1() {
        copy("1")
        let pack = try! Pack(url, id: "1")
        XCTAssertEqual(5, pack.commits.count)
        XCTAssertEqual(5, pack.trees.count)
        XCTAssertEqual(4, pack.blobs.count)
    }
    
    func testLoadPack2() {
        copy("2")
        let pack = try? Pack(url, id: "2")
        XCTAssertEqual(19, pack?.commits.count)
        XCTAssertEqual(70, pack?.trees.count)
        XCTAssertEqual(66, pack?.blobs.count)
        XCTAssertNotNil(pack?.trees.first(where: { $0.0 == "d14d41ee118d52df4b9811b2eacc943f06cd942a" }))
        XCTAssertNotNil(pack?.commits.first(where: { $0.0 == "0807a029cb42acd13ad194248436f093b8e63a4f" }))
        XCTAssertNotNil(pack?.blobs.first(where: { $0.0 == "0ec0ff154d5c479f0af27d7a5064bb570c62500d" }))
        if let data = pack?.trees.first(where: { $0.0 == "d14d41ee118d52df4b9811b2eacc943f06cd942a" })?.1.0.serial {
            XCTAssertEqual("d14d41ee118d52df4b9811b2eacc943f06cd942a", Hub.hash.tree(data).1)
        }
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
        XCTAssertEqual("9b8166fc80d0f0fe9192d4bf1dbaa87f194e012f", try? pack.trees.first?.1.0.save(url))
        XCTAssertEqual("README.md", pack.trees.first?.1.0.items.first?.url.lastPathComponent)
        XCTAssertEqual("""
# test
Test

""", String(decoding: pack.blobs.first!.value.1, as: UTF8.self))
    }
    
    func testLoadFetch1() {
        let pack = try? Pack(Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "fetch1", withExtension: nil)!))
        XCTAssertEqual(23, pack?.commits.count)
        XCTAssertEqual(43, pack?.trees.count)
        XCTAssertEqual(23, pack?.blobs.count)
    }
    
    func testPack0Hash() {
        let data = try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-0.pack", withExtension: nil)!)
        XCTAssertEqual(data.suffix(20), Hub.hash.digest(data.subdata(in: 0 ..< data.count - 20)))
    }
    
    func testPack1Hash() {
        let data = try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-1.pack", withExtension: nil)!)
        XCTAssertEqual(data.suffix(20), Hub.hash.digest(data.subdata(in: 0 ..< data.count - 20)))
    }
    
    func testPack2Hash() {
        let data = try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-2.pack", withExtension: nil)!)
        XCTAssertEqual(data.suffix(20), Hub.hash.digest(data.subdata(in: 0 ..< data.count - 20)))
    }
    
    private func copy(_ id: String) {
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "idx")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
        try! (try! Data(contentsOf: Bundle(for: TestPack.self).url(forResource: "pack-\(id)",
            withExtension: "pack")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
    }
}
