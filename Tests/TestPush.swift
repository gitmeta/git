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
                        XCTAssertEqual(.main, Thread.current)
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
        rest.onPush = { remote, old, new, pack in
            XCTAssertEqual("host.com/monami.git", remote)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.commit([file], message: "My first commit\n") {
                let fetch = Fetch()
                fetch.branch.append(try! Hub.head.id(self.url))
                self.rest._fetch = fetch
                try! Data("hello world updated\n".utf8).write(to: file)
                repository.commit([file], message: "My second commit\n") {
                    repository.push()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOldAndNew() {
        let expect = expectation(description: "")
        var repository: Repository!
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var id = ""
        rest.onPush = { remote, old, new, pack in
            XCTAssertEqual(id, old)
            XCTAssertEqual("host.com/monami.git", remote)
            XCTAssertEqual(try! Hub.head.id(self.url), new)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.commit([file], message: "My first commit\n") {
                let fetch = Fetch()
                id = try! Hub.head.id(self.url)
                fetch.branch.append(id)
                self.rest._fetch = fetch
                try! Data("hello world updated\n".utf8).write(to: file)
                repository.commit([file], message: "My second commit\n") {
                    repository.push()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testPack() {
        let expect = expectation(description: "")
        var repository: Repository!
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        rest.onPush = { remote, old, new, pack in
            let pack = try? Pack(pack)
            XCTAssertNotNil(pack?.commits[new])
            XCTAssertEqual(1, pack?.commits.count)
            XCTAssertEqual(1, pack?.trees.count)
            XCTAssertEqual(1, pack?.blobs.count)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.commit([file], message: "My first commit\n") {
                let fetch = Fetch()
                fetch.branch.append(try! Hub.head.id(self.url))
                self.rest._fetch = fetch
                try! Data("hello world updated\n".utf8).write(to: file)
                repository.commit([file], message: "My second commit\n") {
                    repository.push()
                }
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
            repository.push({ _ in expect.fulfill() })
        }
        waitForExpectations(timeout: 1)
    }
    
    func test3Commits() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        rest.onPush = { remote, old, new, pack in
            let pack = try? Pack(pack)
            XCTAssertEqual(2, pack?.commits.count)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                let fetch = Fetch()
                fetch.branch.append(try! Hub.head.id(self.url))
                self.rest._fetch = fetch
                try! Data("Updated\n".utf8).write(to: file)
                repository.commit([file], message: "Second commit\n") {
                    try! Data("Updated again\n".utf8).write(to: file)
                    repository.commit([file], message: "Third commit\n") {
                        repository.push()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func test2CommitsEmptyResponse() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                let fetch = Fetch()
                fetch.branch.append("another id")
                self.rest._fetch = fetch
                self.rest._push = ""
                try! Data("Updated\n".utf8).write(to: file)
                repository.commit([file], message: "Second commit\n") {
                    repository.push({ _ in
                        expect.fulfill()
                    })
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func test2Commits1Uploaded() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        rest.onPush = { remote, old, new, pack in
            let pack = try? Pack(pack)
            XCTAssertNotNil(pack?.commits[new])
            XCTAssertEqual(1, pack?.commits.count)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                let fetch = Fetch()
                fetch.branch.append(try! Hub.head.id(self.url))
                self.rest._fetch = fetch
                try! Data("Updated\n".utf8).write(to: file)
                repository.commit([file], message: "Second commit\n") {
                    repository.push()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUnknownReference() {
        let expect = expectation(description: "")
        let file = url.appendingPathComponent("file.txt")
        try! Data("hello world\n".utf8).write(to: file)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            repository.commit([file], message: "First commit\n") {
                let fetch = Fetch()
                fetch.branch.append("unknown reference")
                self.rest._fetch = fetch
                try! Data("Updated\n".utf8).write(to: file)
                repository.push({ _ in
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 1)
    }
}
