import XCTest
@testable import Git

class TestAdd: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/objects"), withIntermediateDirectories: true)
        repository = Repository(url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testFirstFile() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        DispatchQueue.global(qos: .background).async {
            self.repository.add(file) {
                let data = try? Data(contentsOf: self.url.appendingPathComponent(".git/index"))
                let index = Index(self.url)
                XCTAssertEqual(Thread.main, Thread.current)
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath:
                    self.url.appendingPathComponent(".git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f").path))
                XCTAssertEqual(19, (try? Data(contentsOf:
                    self.url.appendingPathComponent(".git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f")))?.count)
                XCTAssertEqual(105, data?.count)
                XCTAssertEqual(2, index?.version)
                XCTAssertEqual(40, index?.id.count)
                XCTAssertEqual(1, index?.entries.count)
                XCTAssertEqual("myfile.txt", index?.entries.first?.url.path.dropFirst(self.url.path.count + 1))
                XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", index?.entries.first?.id)
                XCTAssertEqual(19, index?.entries.first?.size)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCompressDecompress() {
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        let press = Press()
        XCTAssertEqual("hello world", String(decoding: press.decompress(press.compress(url.appendingPathComponent("myfile.txt"))), as: UTF8.self))
    }
}
