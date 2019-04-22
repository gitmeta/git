import XCTest
@testable import Git

class TestTree: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testEmpty() {
        XCTAssertTrue(Tree(url).items.isEmpty)
    }
    
    func testAvoidGit() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
        let file = url.appendingPathComponent(".git/myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let tree = Tree(url)
        XCTAssertTrue(tree.items.isEmpty)
    }
    
    func testOneFile() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        let tree = Tree(url)
        XCTAssertEqual(1, tree.items.count)
        XCTAssertEqual(file, tree.items.first?.url)
        XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree.items.first?.id)
        XCTAssertNotNil(tree.items.first as? Tree.Blob)
    }
    
    func testSave() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
        XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", Tree(url).save(url))
        let object = try? Data(contentsOf: url.appendingPathComponent(
            ".git/objects/84/b5f2f96994db6b67f8a0ee508b1ebb8b633c15"))
        XCTAssertNotNil(object)
        XCTAssertEqual(55, object?.count)
    }
}
