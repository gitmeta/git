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
        adv.refs.append("")
        rest._error = Failure.Request.invalid
        rest._adv = adv
        Hub.clone("", local: url, error: { _ in expect.fulfill() })
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfRepository() {
        let expect = expectation(description: "")
        var adv = Fetch()
        adv.refs.append("")
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
        adv.refs.append("")
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
        adv.refs.append("")
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
        adv.refs.append("")
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
        adv.refs.append("")
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
        adv.refs.append("")
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
}
