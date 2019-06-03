import XCTest
@testable import Git

class TestPull: XCTestCase {
    private var url: URL!
    private var file: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.session.name = "hello"
        Hub.session.email = "world"
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testSuccessUpToDate() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.commit([self.file], message: "hello world\n") {
                try? Hub.head.origin(self.url, id: try Hub.head.id(self.url))
                var fetch = Fetch()
                fetch.refs.append((try? Hub.head.id(self.url)) ?? "")
                self.rest._fetch = fetch
                DispatchQueue.global(qos: .background).async {
                    repository.pull {
                        XCTAssertEqual(Thread.main, Thread.current)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailIfNoRemote() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                repository.pull({ _ in
                    XCTAssertEqual(Thread.main, Thread.current)
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCallFetch() {
        let expect = expectation(description: "")
        var repository: Repository!
        rest.onFetch = { expect.fulfill() }
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCallPack() {
        let expect = expectation(description: "")
        var repository: Repository!
        var fetch = Fetch()
        fetch.refs.append("hello world")
        rest._fetch = fetch
        rest.onPack = { _, _ in expect.fulfill() }
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWant() {
        let expect = expectation(description: "")
        var repository: Repository!
        var fetch = Fetch()
        fetch.refs.append("hello world")
        rest._fetch = fetch
        rest.onPack = { want, have in
            XCTAssertEqual("hello world", want)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testHave() {
        let expect = expectation(description: "")
        var repository: Repository!
        var fetch = Fetch()
        fetch.refs.append("hello world")
        rest._fetch = fetch
        rest.onPack = { want, have in
            XCTAssertEqual("0032have 11world 0032have 11hello 0032have 99lorem ", have)
            expect.fulfill()
        }
        Hub.create(url) {
            try? FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/99"), withIntermediateDirectories: true)
            try? FileManager.default.createDirectory(at: self.url.appendingPathComponent(".git/objects/11"), withIntermediateDirectories: true)
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/11/hello"))
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/11/world"))
            try? Data("h".utf8).write(to: self.url.appendingPathComponent(".git/objects/99/lorem"))
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
}
