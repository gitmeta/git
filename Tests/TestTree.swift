import XCTest
@testable import Git

class TestTree: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
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
        XCTAssertEqual("myfile.txt", tree.items.first?.name)
        XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree.items.first?.id)
        XCTAssertNotNil(tree.items.first as? Tree.Blob)
    }
    
    func testSave() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        Tree(url).save(url)
        let object = try? Data(contentsOf: url.appendingPathComponent(
            ".git/objects/74/8f7e72c315f737d829656b9ae627cc857031ed"))
        XCTAssertNotNil(object)
        XCTAssertEqual(58, object?.count)
        print(url.appendingPathComponent(
            ".git/objects/74/8f7e72c315f737d829656b9ae627cc857031ed"))
        print("url")
    }
}
