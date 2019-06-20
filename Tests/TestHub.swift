import XCTest
@testable import Git

class TestHub: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testRepositoryFails() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            Hub.repository(self.url) {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertFalse($0)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepository() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            DispatchQueue.global(qos: .background).async {
                Hub.repository(self.url) {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertTrue($0)
                    expect.fulfill()
                }
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
        
        DispatchQueue.global(qos: .background).async {
            Hub.create(self.url) { _ in
                XCTAssertEqual(.main, Thread.current)
                
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
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        Hub.create(url) { repository in
            DispatchQueue.global(qos: .background).async {
                Hub.delete(repository) {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git").path))
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCreateFailsIfAlreadyExists() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            DispatchQueue.global(qos: .background).async {
                Hub.create(self.url, error: {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertNotNil($0 as? Failure)
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOpenFails() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            Hub.open(self.url, error: { _ in
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { _ in }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOpen() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            DispatchQueue.global(qos: .background).async {
                Hub.open(self.url) { _ in
                    XCTAssertEqual(.main, Thread.current)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testObjects() {
        let expect = expectation(description: "")
        Hub.create(url) { _ in
            try? FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/ab"), withIntermediateDirectories: true)
            try? FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/cd"), withIntermediateDirectories: true)
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/ab/hello"))
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/ab/world"))
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/cd/lorem"))
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/cd/ipsum"))
            let objects = Hub.content.objects(self.url)
            XCTAssertEqual(4, objects.count)
            XCTAssertNotNil(objects.first(where: { $0 == "abhello" }))
            XCTAssertNotNil(objects.first(where: { $0 == "abworld" }))
            XCTAssertNotNil(objects.first(where: { $0 == "cdlorem" }))
            XCTAssertNotNil(objects.first(where: { $0 == "cdipsum" }))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
