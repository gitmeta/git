import XCTest
@testable import Git

class TestClone: XCTestCase {
    private var url: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testFail() {
        let expect = expectation(description: "")
        rest._error = Failure.Request.invalid
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfNoReference() {
        let expect = expectation(description: "")
        rest._fetch = Fetch()
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailOnDownload() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._error = Failure.Request.invalid
        rest._fetch = fetch
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfRepository() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.create(url) { _ in
            Hub.clone("", local: self.url, error: { _ in expect.fulfill() })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSuccess() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        DispatchQueue.global(qos: .background).async {
            Hub.clone("host.com/monami.git", local: self.url.appendingPathComponent("monami")) {
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreatesFolder() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            var d: ObjCBool = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent("monami").path, isDirectory: &d))
            XCTAssertTrue(d.boolValue)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreatesRepository() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            Hub.repository(self.url.appendingPathComponent("monami")) {
                XCTAssertTrue($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHead() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent("monami").appendingPathComponent(".git/index").path))
            XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", try? Hub.head.id(self.url.appendingPathComponent("monami")))
            XCTAssertEqual("Initial commit", try? Hub.head.commit(self.url.appendingPathComponent("monami")).message)
            XCTAssertEqual("54f3a4bf0a60f29d7c4798b590f92ffd56dd6d21", try? Hub.head.tree(self.url.appendingPathComponent("monami")).items.first?.id)
            XCTAssertEqual("master", Hub.head.branch(self.url.appendingPathComponent("monami")))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWantHave() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest.onPull = { remote, want, have in
            XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", want)
            XCTAssertEqual("", have)
            expect.fulfill()
        }
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami"))
        waitForExpectations(timeout: 1)
    }
    
    func testUnpacks() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent("monami").appendingPathComponent("README.md").path))
            XCTAssertEqual("""
# test
Test

""", String(decoding: (try? Data(contentsOf: self.url.appendingPathComponent("monami").appendingPathComponent("README.md"))) ?? Data(), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRemotes() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", String(decoding:
                (try? Data(contentsOf: self.url.appendingPathComponent("monami").appendingPathComponent(".git/refs/remotes/origin/master"))) ?? Data(), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testConfig() {
        let expect = expectation(description: "")
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("host.com/monami.git", local: url.appendingPathComponent("monami")) {
            XCTAssertEqual("""
[remote "origin"]
    url = https://host.com/monami.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master

""", String(decoding: (try? Data(contentsOf: self.url.appendingPathComponent("monami").appendingPathComponent(".git/config"))) ?? Data(), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
