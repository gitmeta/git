import XCTest
@testable import Git

class TestRepository: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testRefresh() {
        let repository = Repository(URL(fileURLWithPath: ""))
        repository.state.last = Date()
        repository.refresh()
        XCTAssertEqual(Date.distantPast, repository.state.last)
    }
    
    func testBranch() {
        let expect = expectation(description: "")
        Hub.create(url) {
            XCTAssertEqual("master", $0.branch)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNotPacked() {
        let expect = expectation(description: "")
        Hub.create(url) {
            XCTAssertFalse($0.packed)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPacked() {
        let expect = expectation(description: "")
        Hub.create(url) {
            try! FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/pack"), withIntermediateDirectories: true)
            try! Data().write(to: self.url.appendingPathComponent(".git/objects/pack/pack-test.pack"))
            XCTAssertTrue($0.packed)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUnpack() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            try! FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/pack"), withIntermediateDirectories: true)
            try! (try! Data(contentsOf: Bundle(for: TestRepository.self).url(forResource: "pack-1",
                withExtension: "idx")!)).write(to: self.url.appendingPathComponent(".git/objects/pack/pack-1.idx"))
            try! (try! Data(contentsOf: Bundle(for: TestRepository.self).url(forResource: "pack-1",
                withExtension: "pack")!)).write(to: self.url.appendingPathComponent(".git/objects/pack/pack-1.pack"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
            repository.unpack {
                XCTAssertEqual(Thread.main, Thread.current)
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/33/5a33ae387dc24f057852fdb92e5abc71bf6b85").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
