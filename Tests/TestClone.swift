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
        rest._adv = Fetch()
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailOnDownload() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._error = Failure.Request.invalid
        rest._adv = adv
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfRepository() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.create(url) { _ in
            Hub.clone("", local: self.url, error: { _ in expect.fulfill() })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfDirectoryWithSameName() {
        let expect = expectation(description: "")
        try? FileManager.default.createDirectory(at: url.appendingPathComponent("monami"), withIntermediateDirectories: true)
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url, error: {
            print($0.localizedDescription)
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testSuccess() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        DispatchQueue.global(qos: .background).async {
            Hub.clone("https://host.com/monami.git", local: self.url) { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testResult() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url) {
            XCTAssertEqual(self.url.appendingPathComponent("monami").path, $0.path)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreatesFolder() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url) {
            var d: ObjCBool = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: $0.path, isDirectory: &d))
            XCTAssertTrue(d.boolValue)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreatesRepository() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url) {
            Hub.repository($0) {
                XCTAssertTrue($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHead() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url) {
            XCTAssertTrue(FileManager.default.fileExists(atPath: $0.appendingPathComponent(".git/index").path))
            XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", try? Hub.head.id($0))
            XCTAssertEqual("Initial commit", try? Hub.head.commit($0).message)
            XCTAssertEqual("54f3a4bf0a60f29d7c4798b590f92ffd56dd6d21", try? Hub.head.tree($0).items.first?.id)
            XCTAssertEqual("master", Hub.head.branch($0))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUnpacks() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._adv = adv
        rest._pack = try? Pack(Data(contentsOf: Bundle(for: TestClone.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.clone("https://host.com/monami.git", local: url) {
            let readme = $0.appendingPathComponent("README.md")
            XCTAssertTrue(FileManager.default.fileExists(atPath: readme.path))
            XCTAssertEqual("""
# test
Test

""", String(decoding: (try? Data(contentsOf: readme)) ?? Data(), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
