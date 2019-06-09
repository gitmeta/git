import XCTest
@testable import Git

class TestPush: XCTestCase {
    private var url: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testSuccessUpToDate() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.commit([file], message: "hello world\n") {
                try? Hub.head.origin(self.url, id: try Hub.head.id(self.url))
                let fetch = Fetch()
                fetch.branch.append((try? Hub.head.id(self.url)) ?? "")
                self.rest._fetch = fetch
                DispatchQueue.global(qos: .background).async {
                    repository.push {
                        XCTAssertEqual(Thread.main, Thread.current)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCallFetch() {
        let expect = expectation(description: "")
        var repository: Repository!
        rest.onUpload = {
            XCTAssertEqual("host.com/monami.git", $0)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.push()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCallPush() {
        let expect = expectation(description: "")
        var repository: Repository!
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        let fetch = Fetch()
        fetch.branch.append("hello world")
        rest._fetch = fetch
        rest.onPush = { remote, want, have in
            XCTAssertEqual("host.com/monami.git", remote)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.commit([file], message: "My first commit\n") {
                repository.push()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoCommits() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("hello world")
        rest._fetch = fetch
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            DispatchQueue.global(qos: .background).async {
                repository.push {
                    XCTAssertEqual(Thread.main, Thread.current)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func test2Commits() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                let fetch = Fetch()
                fetch.branch.append(try! Hub.head.id(self.url))
                self.rest._fetch = fetch
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
