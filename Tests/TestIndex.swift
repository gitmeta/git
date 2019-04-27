import XCTest
@testable import Git

class TestIndex: XCTestCase {
    private var url: URL!
    private var ignore: Ignore!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        ignore = Ignore(url)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testIndexFails() {
        try! Data().write(to: url.appendingPathComponent(".git/index"))
        XCTAssertNil(Index(url))
    }
    
    func testIndexNoExists() {
        XCTAssertNil(Index(url))
    }
    
    func testIndex0() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index0", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(1, index?.entries.count)
        XCTAssertNotNil(index?.entries.first)
        XCTAssertEqual("483a3bef65960a1651d83168f2d1501397617472", index?.id)
        XCTAssertTrue(index?.entries.first?.conflicts == false)
        XCTAssertEqual("afile.json", index?.entries.first?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
        XCTAssertEqual(12, index?.entries.first?.size)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.created)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.modified)
        XCTAssertEqual(16777220, index?.entries.first?.device)
        XCTAssertEqual(10051196, index?.entries.first?.inode)
        XCTAssertEqual(502, index?.entries.first?.user)
        XCTAssertEqual(20, index?.entries.first?.group)
    }
    
    func testIndex0BackAndForth() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index0", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        var index = Index(url)
        try! FileManager.default.removeItem(at: url.appendingPathComponent(".git/index"))
        index?.save(url)
        index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(1, index?.entries.count)
        XCTAssertNotNil(index?.entries.first)
        XCTAssertTrue(index?.entries.first?.conflicts == false)
        XCTAssertEqual("afile.json", index?.entries.first?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", index?.entries.first?.id)
        XCTAssertEqual(12, index?.entries.first?.size)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.created)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554190306), index?.entries.first?.modified)
        XCTAssertEqual(16777220, index?.entries.first?.device)
        XCTAssertEqual(10051196, index?.entries.first?.inode)
        XCTAssertEqual(502, index?.entries.first?.user)
        XCTAssertEqual(20, index?.entries.first?.group)
    }
    
    func testIndex1() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index1", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertTrue(index!.directories.isEmpty)
        XCTAssertEqual("be8343716dab3cb0a2f40813b3f0077bb0cb1a80", index?.id)
    }
    
    func testIndex1BackAndForth() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index1", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        var index = Index(url)
        try! FileManager.default.removeItem(at: url.appendingPathComponent(".git/index"))
        index?.save(url)
        index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertTrue(index!.directories.isEmpty)
    }
    
    func testIndex2() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index2", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual("5b7d07ddf4a539c8344a734364ddc4b17099c5d7", index?.id)
        XCTAssertEqual(2, index?.directories.count)
        XCTAssertEqual("9d59da034b57e98e13dacdb496202495332933e4", index?.directories.first?.id)
        XCTAssertEqual("", index?.directories.first?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual(url, index?.directories.first?.url)
        XCTAssertEqual(22, index?.directories.first?.entries)
        XCTAssertEqual(1, index?.directories.first?.sub)
        XCTAssertEqual("7a54af5932f25ec362249f33aa6b730bacdf58cb", index?.directories.last?.id)
        XCTAssertEqual("some directory", index?.directories.last?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual(2, index?.directories.last?.entries)
        XCTAssertEqual(0, index?.directories.last?.sub)
    }
    
    func testIndex2BackAndForth() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index2", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        var index = Index(url)
        try! FileManager.default.removeItem(at: url.appendingPathComponent(".git/index"))
        index?.save(url)
        index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual(2, index?.directories.count)
        XCTAssertEqual("9d59da034b57e98e13dacdb496202495332933e4", index?.directories.first?.id)
        XCTAssertEqual("", index?.directories.first?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual(22, index?.directories.first?.entries)
        XCTAssertEqual(1, index?.directories.first?.sub)
        XCTAssertEqual("7a54af5932f25ec362249f33aa6b730bacdf58cb", index?.directories.last?.id)
        XCTAssertEqual("some directory", index?.directories.last?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual(2, index?.directories.last?.entries)
        XCTAssertEqual(0, index?.directories.last?.sub)
    }
    
    func testIndex3() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index3", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual("22540a368e9c10d2ead5c097626cc2b2ea0cc0ac", index?.id)
        XCTAssertEqual(2, index?.directories.count)
    }
    
    func testIndex3BackAndForth() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index3", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        var index = Index(url)
        try! FileManager.default.removeItem(at: url.appendingPathComponent(".git/index"))
        index?.save(url)
        index = Index(url)
        XCTAssertNotNil(index)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(22, index?.entries.count)
        XCTAssertEqual(2, index?.directories.count)
    }
    
    func testIndex4() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index4", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertNotNil(index?.entries.first(where: { $0.id == "4545025894f8bd0408a845a9072198a887245b29" }))
        XCTAssertNotNil(index?.entries.first(where: { $0.url.path.contains("ARPresenter.swift") }))
        XCTAssertNotNil(index?.directories.first(where: { $0.id == "74a0e95d56601e55663e28590304d8f9bcdd9ddf" }))
        XCTAssertNotNil(index?.directories.first(where: { $0.id == "74a0e95d56601e55663e28590304d8f9bcdd9ddf" }))
        XCTAssertEqual(334, index?.entries.count)
        XCTAssertEqual(62, index?.directories.count)
        index!.directories.forEach { print($0.id + " : " + $0.url.path) }
    }
    
    func testIndex5() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index5", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        print(index!.id)
        print(index!.version)
        print(index!.entries.first!)
    }
    
    func testIndex6() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index6", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        print(index!.id)
        print(index!.version)
        index!.entries.forEach({ print($0) })
    }
    
    func testIndex7() {
        try! (try! Data(contentsOf: Bundle(for: TestIndex.self).url(forResource: "index7", withExtension: nil)!)).write(to:
            url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertEqual(2, index?.entries.count)
        print(index!.id)
        print(index!.version)
        index!.entries.forEach({ print($0) })
    }
    
    func testAddEntry() {
        let file = url.appendingPathComponent("file.txt")
        try! "hello world".write(to: file, atomically: true, encoding: .utf8)
        let index = Index()
        index.entry("asd", url: file)
        XCTAssertEqual(1, index.entries.count)
        XCTAssertEqual(file, index.entries.first?.url)
        XCTAssertEqual("asd", index.entries.first?.id)
        XCTAssertEqual(11, index.entries.first?.size)
    }
    
    func testAddTree() {
        let file = url.appendingPathComponent("file.txt")
        try! "hello world".write(to: file, atomically: true, encoding: .utf8)
        let index = Index()
        let tree = Tree(url, ignore: ignore, valid: [file])
        index.main("22540a368e9c10d2ead5c097626cc2b2ea0cc0ac", url: url, tree: tree)
        XCTAssertEqual(1, index.directories.count)
        XCTAssertEqual(url, index.directories.first?.url)
        XCTAssertEqual(1, index.directories.first?.entries)
        XCTAssertEqual(0, index.directories.first?.sub)
        XCTAssertEqual("22540a368e9c10d2ead5c097626cc2b2ea0cc0ac", index.directories.first?.id)
    }
    
    func testAddTreeBackAndForth() {
        let file = url.appendingPathComponent("file.txt")
        try! "hello world".write(to: file, atomically: true, encoding: .utf8)
        var index = Index()
        let tree = Tree(url, ignore: ignore, valid: [file])
        index.main("22540a368e9c10d2ead5c097626cc2b2ea0cc0ac", url: url, tree: tree)
        index.save(url)
        index = Index(url)!
        XCTAssertNotNil(index)
        XCTAssertEqual(1, index.directories.count)
        XCTAssertEqual(url, index.directories.first?.url)
        XCTAssertEqual(1, index.directories.first?.entries)
        XCTAssertEqual(0, index.directories.first?.sub)
        XCTAssertEqual("22540a368e9c10d2ead5c097626cc2b2ea0cc0ac", index.directories.first?.id)
    }
}
