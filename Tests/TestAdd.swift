import XCTest
@testable import Git

class TestAdd: XCTestCase {
    private var repository: Repository!
    private var url: URL!
    
    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/objects"),
                                                 withIntermediateDirectories: true)
        repository = Repository(url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }
    
    func testFirstFile() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        try? repository.add(file)
        let data = try? Data(contentsOf: url.appendingPathComponent(".git/index"))
        let index = Index(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/index").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath:
            url.appendingPathComponent(".git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f").path))
        XCTAssertEqual(27, (try? Data(contentsOf:
            url.appendingPathComponent(".git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f")))?.count)
        XCTAssertEqual(105, data?.count)
        XCTAssertEqual(2, index?.version)
        XCTAssertEqual(40, index?.id.count)
        XCTAssertEqual(1, index?.entries.count)
        XCTAssertEqual("myfile.txt", index?.entries.first?.url.path.dropFirst(url.path.count + 1))
        XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", index?.entries.first?.id)
        XCTAssertEqual(11, index?.entries.first?.size)
    }
    
    func testDoubleAdd() {
        let file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        try? repository.add(file)
        XCTAssertThrowsError(try repository.add(file))
    }
    
    func testCompressDecompress() {
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        let press = Press()
        XCTAssertEqual("hello world", String(decoding: press.decompress(press.compress(
            try! Data(contentsOf: url.appendingPathComponent("myfile.txt")))), as: UTF8.self))
    }
    
    func testNonExistingFile() {
        let file = url.appendingPathComponent("myfile.txt")
        XCTAssertThrowsError(try repository.add(file))
    }
    
    func testOutsideProject() {
        let file = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myfile.txt")
        try! Data("hello world".utf8).write(to: file)
        XCTAssertThrowsError(try repository.add(file))
    }
}
