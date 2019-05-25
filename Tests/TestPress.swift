import XCTest
@testable import Git

class TestPress: XCTestCase {
    private var repository: Repository!
    private var press: Press!
    private var url: URL!

    override func setUp() {
        press = Press()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/objects/ab"), withIntermediateDirectories: true)
        repository = Repository(url)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testCompressed0() {
        XCTAssertEqual("""
hello world
""", String(decoding: press.decompress(try!
    Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "compressed0", withExtension: nil)!)), as: UTF8.self))
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
        try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree1", withExtension: nil)!).write(to:
            url.appendingPathComponent(".git/objects/ab/helloworld"))
        let tree = try? Tree("abhelloworld", url: url)
        XCTAssertEqual(1, tree?.items.count)
        XCTAssertEqual(.blob, tree?.items.first?.category)
        XCTAssertEqual("hello.json", tree?.items.first?.url.lastPathComponent)
        XCTAssertEqual("e0f1ee1826f922f041e557a16173f2a93835825e", tree?.items.first?.id)
    }
    
    func testTree2() {
        try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree2", withExtension: nil)!).write(to:
            url.appendingPathComponent(".git/objects/ab/helloworld"))
        let tree = try? Tree("abhelloworld", url: url)
        XCTAssertEqual(2, tree?.items.count)
        XCTAssertEqual(.blob, tree?.items.first?.category)
        XCTAssertEqual(.tree, tree?.items.last?.category)
        XCTAssertEqual("hello.json", tree?.items.first?.url.lastPathComponent)
        XCTAssertEqual("e0f1ee1826f922f041e557a16173f2a93835825e", tree?.items.first?.id)
        XCTAssertEqual("mydir", tree?.items.last?.url.lastPathComponent)
        XCTAssertEqual("213190a0fbccf0c01ebf2776edb8011fd935dbba", tree?.items.last?.id)
    }
    
    func testTree3() {
        try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree3", withExtension: nil)!).write(to:
            url.appendingPathComponent(".git/objects/ab/helloworld"))
        let tree = try? Tree("abhelloworld", url: url)
        XCTAssertEqual(11, tree?.items.count)
        XCTAssertEqual(11, tree?.items.filter({ $0.category != .tree }).count)
    }
    
    func testTree4() {
        try! Data(contentsOf: Bundle(for: TestPress.self).url(forResource: "tree4", withExtension: nil)!).write(to:
            url.appendingPathComponent(".git/objects/ab/helloworld"))
        let tree = try? Tree("abhelloworld", url: url)
        XCTAssertNotNil(tree?.items.first(where: { $0.id == "71637250a143a4c2eed7103f08b3610cd4f1f1f9" }))
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
        XCTAssertNil(commit?.parent.first)
        XCTAssertEqual("99ff9f93b7f0f7d300dc3c42d16cdfcdf5c2a82f", commit?.tree)
        XCTAssertEqual("vauxhall", commit?.author.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.author.email)
        XCTAssertEqual("vauxhall", commit?.committer.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.committer.email)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554638195), commit?.author.date)
        XCTAssertEqual(Date(timeIntervalSince1970: 1554638195), commit?.committer.date)
        XCTAssertEqual("This is my first commit.\n", commit?.message)
        XCTAssertEqual("", commit?.gpg)
    }
    
    func testParseCommit1() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit1", withExtension: nil)!)))
        XCTAssertEqual("0cbd117f7fe2ec884168863af047e8c89e71aaf1", commit?.parent.first)
        XCTAssertEqual("", commit?.gpg)
    }
    
    func testParseCommit2() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit2", withExtension: nil)!)))
        XCTAssertEqual("890be9af6d5a18a1eb999f0ad44c15a83f227af4", commit?.parent.first)
        XCTAssertEqual("d27de8c22fb0cfdc7d12f8eaf30bcc5343e7f70a", commit?.parent.last)
        XCTAssertEqual("a50257e1731e34b6be3db840155ff86c3b5a26e2", commit?.tree)
        XCTAssertEqual("vauxhall", commit?.author.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.author.email)
        XCTAssertEqual("+0200", commit?.author.timezone)
        XCTAssertEqual("vauxhall", commit?.committer.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.committer.email)
        XCTAssertEqual("+0200", commit?.committer.timezone)
        XCTAssertEqual(Date(timeIntervalSince1970: 1557728927), commit?.author.date)
        XCTAssertEqual(Date(timeIntervalSince1970: 1557728927), commit?.committer.date)
        XCTAssertEqual("Merge branch \'master\' of https://github.com/vauxhall/merge\n", commit?.message)
        XCTAssertEqual("", commit?.gpg)
    }
    
    func testParseCommit2BackAndForth() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit2", withExtension: nil)!)))
        XCTAssertEqual("79be52211d61ef2e59134ae6e8aaa0fe121de71f", Hash().commit(commit!.serial).1)
    }
    
    func testParseCommit3() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit3", withExtension: nil)!)))
        XCTAssertEqual("8dc0abf0a0b0d70a0a8680daa69a7df74acfce95", commit?.parent.first)
        XCTAssertEqual("9177be007bb25b1f12ecc3fd14eb191cd07d69f4", commit?.tree)
        XCTAssertEqual("vauxhall", commit?.author.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit?.author.email)
        XCTAssertEqual("GitHub", commit?.committer.name)
        XCTAssertEqual("noreply@github.com", commit?.committer.email)
        XCTAssertEqual(Date(timeIntervalSince1970: 1557728914), commit?.author.date)
        XCTAssertEqual(Date(timeIntervalSince1970: 1557728914), commit?.committer.date)
        XCTAssertEqual("Create another.txt", commit?.message)
        XCTAssertEqual("""
\ngpgsig -----BEGIN PGP SIGNATURE-----\n \n wsBcBAABCAAQBQJc2Q6SCRBK7hj4Ov3rIwAAdHIIAG87iBwa22KVe14mZRay8eNm\n zIBtaLODH51ETcpmjFouPM59Zp1jrVtyuqa3RCj2Ijsrj0VVNfIET9XTd/LfHnvM\n oel2lT69YtWUvu6Dnm7NhyaMvgqhfTytF4W3uXd5FB1aTwyv2cUNq5y+fNzqjYlY\n kxDiyVX2Efg54yyDsO1GbWR20ij3m9lR7GrysX2oS135WatX62w0zmQHoslrbjPT\n zAJaherlmbXG07A6yoRajdp/o+Tujf/irjMVWBwuYy3WI96U+Mj5CuFHgQvVq3om\n sb+wQXR0sq9g1x5v/rC780IsuNzj8hl3eVj6PQMzlTdqUBYwJxCzMMQXPeYQ5z8=\n =GDUq\n -----END PGP SIGNATURE-----\n \

""", commit?.gpg)
    }
    
    func testParseCommit3BackAndForth() {
        let commit = try? Commit(press.decompress(try! Data(contentsOf: Bundle(for: TestPress.self).url(
            forResource: "commit3", withExtension: nil)!)))
        XCTAssertEqual("d27de8c22fb0cfdc7d12f8eaf30bcc5343e7f70a", Hash().commit(commit!.serial).1)
    }
}
