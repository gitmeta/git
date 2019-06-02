import XCTest
@testable import Git

class TestConfig: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/"), withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testInvalid() {
        XCTAssertThrowsError(try Config(url))
    }
    
    func testParse() {
        try? Data(contentsOf: Bundle(for: TestConfig.self).url(forResource: "config0", withExtension: nil)!).write(to: url.appendingPathComponent(".git/config"))
        let config = try? Config(url)
        XCTAssertEqual(1, config?.remote.count)
        XCTAssertEqual(1, config?.branch.count)
        XCTAssertEqual("origin", config?.remote.first?.0)
        XCTAssertEqual("https://github.com/vauxhall/merge.git", config?.remote.first?.1.url)
        XCTAssertEqual("+refs/heads/*:refs/remotes/origin/*", config?.remote.first?.1.fetch)
        XCTAssertEqual("master", config?.branch.first?.0)
        XCTAssertEqual("origin", config?.branch.first?.1.remote)
        XCTAssertEqual("refs/heads/master", config?.branch.first?.1.merge)
        XCTAssertEqual("""
[remote "origin"]
    url = https://github.com/vauxhall/merge.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master

""", config?.serial)
    }
    
    func testSave() {
        let config = Config()
        var remote = Config.Remote()
        remote.url = "lorem ipsum"
        remote.fetch = "hello world"
        config.remote["hello"] = remote
        try? config.save(url)
        XCTAssertEqual("""
[remote "hello"]
    url = lorem ipsum
    fetch = hello world

""", String(decoding: (try? Data(contentsOf: url.appendingPathComponent(".git/config"))) ?? Data(), as: UTF8.self))
    }
}
