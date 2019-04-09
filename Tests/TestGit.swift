import XCTest
@testable import Pigit

class TestGit: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory())
        clear()
    }
    
    override func tearDown() {
        clear()
    }
    
    func testRepositoryFails() {
        let expect = expectation(description: "")
        Git.repository(url) {
            XCTAssertEqual(Thread.main, Thread.current)
            
            XCTAssertFalse($0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepository() {
        let expect = expectation(description: "")
        Git.create(url) { _ in
            Git.repository(self.url) {
                XCTAssertEqual(Thread.main, Thread.current)
                
                XCTAssertTrue($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreate() {
        let expect = expectation(description: "")
        let root = url.appendingPathComponent(".git")
        let refs = root.appendingPathComponent("refs")
        let objects = root.appendingPathComponent("objects")
        let head = root.appendingPathComponent("HEAD")
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
        Git.create(url) { _ in
            XCTAssertEqual(Thread.main, Thread.current)
            
            var directory: ObjCBool = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.path, isDirectory: &directory))
            XCTAssertTrue(directory.boolValue)
            XCTAssertTrue(FileManager.default.fileExists(atPath: refs.path, isDirectory: &directory))
            XCTAssertTrue(directory.boolValue)
            XCTAssertTrue(FileManager.default.fileExists(atPath: objects.path, isDirectory: &directory))
            XCTAssertTrue(directory.boolValue)
            XCTAssertTrue(FileManager.default.fileExists(atPath: head.path, isDirectory: &directory))
            XCTAssertFalse(directory.boolValue)
            
            var data = Data()
            XCTAssertNoThrow(data = (try? Data(contentsOf: head)) ?? data)
            let content = String(decoding: data, as: UTF8.self)
            XCTAssertTrue(content.contains("ref: refs/"))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        Git.create(url) {
            Git.delete($0) {
                XCTAssertEqual(Thread.main, Thread.current)
                
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git").path))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreateFailsIfAlreadyExists() {
        let expect = expectation(description: "")
        Git.create(url) { _ in
            Git.create(self.url, error: {
                XCTAssertEqual(Thread.main, Thread.current)
                
                XCTAssertNotNil($0 as? Failure)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOpenFails() {
        let expect = expectation(description: "")
        Git.open(url, error: { _ in
            XCTAssertEqual(Thread.main, Thread.current)
            
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testOpen() {
        let expect = expectation(description: "")
        Git.create(url) { _ in
            Git.open(self.url) { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    private func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}
