import XCTest
@testable import Git

class TestUnpackRepository: XCTestCase {
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
    
    func testNotPacked() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                repository.packed {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertFalse($0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPacked() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            self.addPack()
            repository.packed {
                XCTAssertTrue($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPackedReference() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            self.addReference()
            repository.packed {
                XCTAssertTrue($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUnpack() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            self.addPack()
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
            DispatchQueue.global(qos: .background).async {
                repository.unpack {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/33/5a33ae387dc24f057852fdb92e5abc71bf6b85").path))
                    XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/objects/pack/pack-1.pack").path))
                    
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReferences() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            self.addPack()
            self.addReference()
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/packed-refs").path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/refs/heads/master").path))
            repository.unpack {
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/refs/heads/master").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/packed-refs").path))
                XCTAssertEqual("335a33ae387dc24f057852fdb92e5abc71bf6b85", try? Hub.head.id(self.url))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    private func addPack() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/objects/pack"), withIntermediateDirectories: true)
        try! (try! Data(contentsOf: Bundle(for: TestUnpackRepository.self).url(forResource: "pack-1",
                                                                               withExtension: "idx")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-1.idx"))
        try! (try! Data(contentsOf: Bundle(for: TestUnpackRepository.self).url(forResource: "pack-1",
                                                                               withExtension: "pack")!)).write(to: url.appendingPathComponent(".git/objects/pack/pack-1.pack"))
    }
    
    private func addReference() {
        try! (try! Data(contentsOf: Bundle(for: TestUnpackRepository.self).url(forResource: "packed-refs0",
                                                                               withExtension: nil)!)).write(to: self.url.appendingPathComponent(".git/packed-refs"))
    }
}
