import XCTest
@testable import Pigit

class TestPress: XCTestCase {
    private var press: Press!

    override func setUp() {
        press = Press()
    }
    
    func testBlob0() {
        XCTAssertEqual("""
blob 12\u{0000}hello rorld

""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "blob0", withExtension: nil)!)), as: UTF8.self))
    }
    
    func testTree0() {
        XCTAssertEqual(839, press.decompress(try!
            Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree0", withExtension: nil)!)).count)
    }
    
    func testTree1() {
        let tree = try? Tree(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree1",
                                                                                                    withExtension: nil)!)))
        XCTAssertEqual(1, tree?.items.count)
        XCTAssertNotNil(tree?.items.first as? Tree.Blob)
        XCTAssertEqual("hello.json", tree?.items.first?.name)
        XCTAssertEqual("e0f1ee1826f922f041e557a16173f2a93835825e", tree?.items.first?.id)
    }
    
    func testTree2() {
        let tree = try? Tree(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree2",
                                                                                                    withExtension: nil)!)))
        XCTAssertEqual(2, tree?.items.count)
        XCTAssertNotNil(tree?.items.first as? Tree.Blob)
        XCTAssertNotNil(tree?.items.last as? Tree.Tree)
        XCTAssertEqual("hello.json", tree?.items.first?.name)
        XCTAssertEqual("e0f1ee1826f922f041e557a16173f2a93835825e", tree?.items.first?.id)
        XCTAssertEqual("mydir", tree?.items.last?.name)
        XCTAssertEqual("213190a0fbccf0c01ebf2776edb8011fd935dbba", tree?.items.last?.id)
    }
    
    func testCommit0() {
        XCTAssertEqual("""
commit 191\u{0000}tree 99ff9f93b7f0f7d300dc3c42d16cdfcdf5c2a82f
author vauxhall <zero.griffin@gmail.com> 1554638195 +0200
committer vauxhall <zero.griffin@gmail.com> 1554638195 +0200

This is my first commit.

""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "commit0", withExtension: nil)!)), as: UTF8.self))
    }
    
    func testCommit1() {
        XCTAssertEqual("""
commit 232\u{0000}tree 250202b9788cc1edd675dabec0081004179475f8
parent 0cbd117f7fe2ec884168863af047e8c89e71aaf1
author vauxhall <zero.griffin@gmail.com> 1554641683 +0200
committer vauxhall <zero.griffin@gmail.com> 1554641683 +0200

My second commit.

""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "commit1", withExtension: nil)!)), as: UTF8.self))
    }
    
    func testParseCommit0() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit0", withExtension: nil)!)))
        XCTAssertNil(commit?.parent)
        XCTAssertEqual("99ff9f93b7f0f7d300dc3c42d16cdfcdf5c2a82f", commit?.tree)
        XCTAssertEqual("vauxhall", commit?.author.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.author.email)
        XCTAssertEqual("vauxhall", commit?.committer.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.committer.email)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554638195), commit?.author.date)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554638195), commit?.committer.date)
    }
    
    func testParseCommit1() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit1", withExtension: nil)!)))
        XCTAssertEqual("0cbd117f7fe2ec884168863af047e8c89e71aaf1", commit?.parent)
    }
}
