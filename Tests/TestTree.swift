import XCTest
@testable import Git

class TestTree: XCTestCase {
    private var url: URL!
    private var ignore: Ignore!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        ignore = Ignore(url)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testEmpty() {
        XCTAssertTrue(Tree(url, ignore: ignore, valid: []).items.isEmpty)
    }
    
    func testAvoidGit() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let file = url.appendingPathComponent(".git/myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let tree = Tree(url, ignore: ignore, valid: [])
        XCTAssertTrue(tree.items.isEmpty)
    }
    
    func testOneFileNotValid() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let tree = Tree(url, ignore: ignore, valid: [])
        XCTAssertTrue(tree.items.isEmpty)
    }
    
    func testOneFile() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let tree = Tree(url, ignore: ignore, valid: [file])
        XCTAssertEqual(1, tree.items.count)
        XCTAssertEqual(file, tree.items.first?.url)
        XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree.items.first?.id)
        XCTAssertNotNil(tree.items.first as? Tree.Blob)
    }
    
    func testSave() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
        XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", Tree(url, ignore: ignore, valid: [file]).save(url))
        let object = try? Data(contentsOf: url.appendingPathComponent(
            ".git/objects/84/b5f2f96994db6b67f8a0ee508b1ebb8b633c15"))
        XCTAssertNotNil(object)
        XCTAssertEqual(55, object?.count)
    }
    
    func testOneFileInSub() {
        let sub = url.appendingPathComponent("abc", isDirectory: true)
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let file = sub.appendingPathComponent("another.txt")
        try! Data("lorem ipsum\n".utf8).write(to: file)
        let tree = Tree(url, ignore: ignore, valid: [file])
        XCTAssertEqual(1, tree.items.count)
        XCTAssertNotNil(tree.items.first as? Tree.Sub)
        XCTAssertEqual(sub, tree.items.first?.url)
        XCTAssertEqual("12b34e53d16df3d9f2dd6ad8a4c45af37e283dc1", tree.items.first?.id)
        XCTAssertEqual(sub, tree.items.first?.url)
        XCTAssertEqual(1, tree.children.count)
        XCTAssertNotNil(tree.children.first?.items.first as? Tree.Blob)
        XCTAssertEqual("01a59b011a48660bb3828ec72b2b08990b8cf56b", tree.children.first?.items.first?.id)
        XCTAssertEqual(file, tree.children.first?.items.first?.url)
    }
    
    func testSaveSub() {
        let sub = url.appendingPathComponent("abc")
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let file = sub.appendingPathComponent("another.txt")
        try! Data("lorem ipsum".utf8).write(to: file)
        XCTAssertEqual("869b9c7ef21df1511a4a1cded69b0b011fe0e8c3", Tree(url, ignore: ignore, valid: [file]).save(url))
        let object = try? Data(contentsOf: url.appendingPathComponent(
            ".git/objects/86/9b9c7ef21df1511a4a1cded69b0b011fe0e8c3"))
        XCTAssertNotNil(object)
        XCTAssertEqual(45, object?.count)
    }
    
    func testEmptySub() {
        let sub = url.appendingPathComponent("abc")
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let tree = Tree(url, ignore: ignore, valid: [])
        XCTAssertTrue(tree.items.isEmpty)
    }
    
    func testEmptySubInSub() {
        let sub = url.appendingPathComponent("abc")
        try! FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        let another = sub.appendingPathComponent("def")
        try! FileManager.default.createDirectory(at: another, withIntermediateDirectories: true)
        let tree = Tree(url, ignore: ignore, valid: [])
        XCTAssertTrue(tree.items.isEmpty)
    }
}
