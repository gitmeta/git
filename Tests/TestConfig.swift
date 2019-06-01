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
    
    func testParse() {
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
}
