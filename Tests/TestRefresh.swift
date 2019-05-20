import XCTest
@testable import Git

class TestRefresh: XCTestCase {
    private var url: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testAfterCommit() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            repository.status = { _ in
                expect.fulfill()
            }
            repository.state.delta = 0
            repository.commit([file], message: "hello world\n")
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterReset() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file = self.url.appendingPathComponent("myfile.txt")
            try! Data("hello world\n".utf8).write(to: file)
            repository.commit([file], message: "My first commit\n") {
                repository.status = { _ in
                    expect.fulfill()
                }
                repository.state.delta = 0
                repository.reset()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAfterUnpack() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.status = { _ in
                expect.fulfill()
            }
            repository.state.delta = 0
            repository.unpack()
        }
        waitForExpectations(timeout: 1)
    }
}
