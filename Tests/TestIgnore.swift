import XCTest
@testable import Git

class TestIgnore: XCTestCase {
    private var url: URL!
    private var ignore: Ignore!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try! """
.DS_Store
*.xcuserstate
.dSYM*
/something
Pods/
/More/

""".write(to: url.appendingPathComponent(".gitignore"), atomically: true, encoding: .utf8)
        ignore = Ignore(url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testAccept() {
        XCTAssertFalse(ignore.url(url))
        XCTAssertFalse(ignore.url(url.appendingPathComponent("afile.txt")))
    }
    
    func testGit() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent("test.git")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent("git")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent(".gito")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent(".gitignore")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".git")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".git/HEAD")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".git/some/other/thing")))
    }
    
    func testExplicit() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent(".DS_Storea")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent("DS_Store")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent("world.DS_Store")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".DS_Store")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("hello/.DS_Store")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("something")))
    }
    
    func testFolders() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent("Any/other")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("Any", isDirectory: true)))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("Other", isDirectory: true)))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("Any/Other", isDirectory: true)))
    }
    
    func testFolderContents() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent("aPods/thing")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("Pods/thing")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("More/thing")))
    }
    
    func testPrefixStar() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent(".xcuserstatea")))
        XCTAssertFalse(ignore.url(url.appendingPathComponent(".xcuserstate/a")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("hallo.xcuserstate")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".xcuserstate")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("hello/world/.xcuserstate")))
    }
    
    func testSuffixStar() {
        XCTAssertFalse(ignore.url(url.appendingPathComponent("a.dSYM")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".dSYM.zip")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".dSYM")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".dSYM/addas")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent(".dSYM/x/y/z")))
        XCTAssertTrue(ignore.url(url.appendingPathComponent("asdsa/.dSYM")))
    }
}
