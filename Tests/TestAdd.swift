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
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        DispatchQueue.global(qos: .background).async {
            self.repository.add("myfile.txt") {
                let data = try? Data(contentsOf: self.url.appendingPathComponent(".git/index"))
                let index = Index.load(self.url)
                XCTAssertEqual(Thread.main, Thread.current)
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath:
                    self.url.appendingPathComponent(".git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f").path))
                XCTAssertEqual(32, data?.count)
                XCTAssertEqual(2, index?.version)
                XCTAssertEqual("39d890139ee5356c7ef572216cebcd27aa41f9df", index?.id)
                XCTAssertEqual(0, index?.entries.count)
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
