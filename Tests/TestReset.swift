import XCTest
@testable import Git

class TestReset: XCTestCase {
    private var url: URL!
    private var repository: Repository!
    
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testResetOneFile() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            Hub.session.name = "hello"
            Hub.session.email = "world"
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
            self.repository.commit([file], message: "My first commit\n") {
                try! FileManager.default.removeItem(at: file)
                XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
                DispatchQueue.global(qos: .background).async {
                    self.repository.reset {
                        XCTAssertEqual(Thread.main, Thread.current)
                        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
                        XCTAssertEqual("hello world\n",
                                       String(decoding: (try? Data(contentsOf: file)) ?? Data(), as: UTF8.self))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testResetSubdirectories() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            Hub.session.name = "hello"
            Hub.session.email = "world"
            let dir = self.url.appendingPathComponent("dir1")
            try! FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false)
            let file1 = self.url.appendingPathComponent("myfile1.txt")
            let file2 = dir.appendingPathComponent("myfile2.txt")
            try! Data("hello world\n".utf8).write(to: file1)
            try! Data("lorem ipsum\n".utf8).write(to: file2)
            XCTAssertTrue(FileManager.default.fileExists(atPath: file1.path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: file2.path))
            self.repository.commit([file1, file2], message: "My first commit\n") {
                try! FileManager.default.removeItem(at: file1)
                try! FileManager.default.removeItem(at: dir)
                XCTAssertFalse(FileManager.default.fileExists(atPath: file1.path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: file2.path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: dir.path))
                self.repository.reset {
                    XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path))
                    XCTAssertTrue(FileManager.default.fileExists(atPath: file1.path))
                    XCTAssertEqual("hello world\n",
                                   String(decoding: (try? Data(contentsOf: file1)) ?? Data(), as: UTF8.self))
                    XCTAssertTrue(FileManager.default.fileExists(atPath: file2.path))
                    XCTAssertEqual("lorem ipsum\n",
                                   String(decoding: (try? Data(contentsOf: file2)) ?? Data(), as: UTF8.self))
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
