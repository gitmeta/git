import XCTest
@testable import Git

class TestDiff: XCTestCase {
    private var url: URL!
    private var repository: Repository!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testOneChange() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            self.repository.commit([file], message: "My first commit\n") {
                try! Data("Lorem ipsum\n".utf8).write(to: file)
                DispatchQueue.global(qos: .background).async {
                    self.repository.previous(file, error: { _ in }) {
                        XCTAssertEqual(.main, Thread.current)
                        XCTAssertNotNil($0)
                        XCTAssertEqual("hello world\n", String(decoding: $0!.1, as: UTF8.self))
                        XCTAssertGreaterThanOrEqual(Date(), $0!.0)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNewFile() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            let file1 = self.url.appendingPathComponent("myfile1.txt")
            let file2 = self.url.appendingPathComponent("myfile2.txt")
            try! Data("hello world\n".utf8).write(to: file1)
            self.repository.commit([file1], message: "My first commit\n") {
                try! Data("Lorem ipsum\n".utf8).write(to: file2)
                self.repository.previous(file2, error: { _ in }) {
                    XCTAssertNil($0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoChange() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            self.repository.commit([file], message: "My first commit\n") {
                DispatchQueue.global(qos: .background).async {
                    self.repository.previous(file, error: { _ in
                        XCTAssertEqual(.main, Thread.current)
                        expect.fulfill()
                    }) { _ in }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTimeline() {
        let expect = expectation(description: "")
        Hub.create(url) {
            self.repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            self.repository.commit([file], message: "My first commit\n") {
                try! Data("Lorem ipsum\n".utf8).write(to: file)
                self.repository.commit([file], message: "My second commit\n") {
                    try! Data("Lorem ipsum\nWith some updates".utf8).write(to: file)
                    DispatchQueue.global(qos: .background).async {
                        self.repository.timeline(file, error: { _ in }) {
                            XCTAssertEqual(.main, Thread.current)
                            XCTAssertEqual(3, $0.count)
                            XCTAssertEqual("Lorem ipsum\nWith some updates", String(decoding: $0[0].1, as: UTF8.self))
                            XCTAssertEqual("Lorem ipsum\n", String(decoding: $0[1].1, as: UTF8.self))
                            XCTAssertEqual("hello world\n", String(decoding: $0[2].1, as: UTF8.self))
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
