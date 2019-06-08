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
                let fetch = Fetch()
                fetch.branch.append((try? Hub.head.id(self.url)) ?? "")
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
        rest.onFetch = {
            XCTAssertEqual("host.com/monami.git", $0)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCallPack() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("hello world")
        rest._fetch = fetch
        rest.onPull = { remote, want, have in
            XCTAssertEqual("host.com/monami.git", remote)
            expect.fulfill()
        }
        Hub.create(url) {
            repository = $0
            try? Config("host.com/monami.git").save(self.url)
            repository.pull()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWant() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("hello world")
        rest._fetch = fetch
        rest.onPull = { remote, want, have in
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
        let fetch = Fetch()
        fetch.branch.append("hello world")
        rest._fetch = fetch
        rest.onPull = { remote, want, have in
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
    
    func testCheckout() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestPull.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull {
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(".git/index").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent("README.md").path))
                XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", try? Hub.head.id(self.url))
                XCTAssertEqual("Initial commit", try? Hub.head.commit(self.url).message)
                XCTAssertEqual("54f3a4bf0a60f29d7c4798b590f92ffd56dd6d21", try? Hub.head.tree(self.url).items.first?.id)
                XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", String(decoding:
                    (try? Data(contentsOf: self.url.appendingPathComponent(".git/refs/remotes/origin/master"))) ?? Data(), as: UTF8.self))
                XCTAssertEqual("""
# test
Test

""", String(decoding: (try? Data(contentsOf: self.url.appendingPathComponent("README.md"))) ?? Data(), as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateConfig() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                repository.remote("host.com/monami.git") {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertEqual("""
[remote "origin"]
    url = https://host.com/monami.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
    remote = origin
    merge = refs/heads/master

""", String(decoding: (try? Data(contentsOf: self.url.appendingPathComponent(".git/config"))) ?? Data(), as: UTF8.self))
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testMergeFailNoCommonAncestor() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("54cac1e1086e2709a52d7d1727526b14efec3a77")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestPull.self).url(forResource: "fetch0", withExtension: nil)!))
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.commit([self.file], message: "This is a commit that should not be in the history.\n") {
                repository.pull({ _ in
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testMerge() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("335a33ae387dc24f057852fdb92e5abc71bf6b85")
        rest._fetch = fetch
        rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestPull.self).url(forResource: "fetch2", withExtension: nil)!))
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull {
                XCTAssertEqual(4, try! FileManager.default.contentsOfDirectory(atPath: self.url.path).count)
                self.rest._fetch!.branch = ["4ec6903ca199e0e92c6cd3abb5b95f3b7f3d7e4d"]
                self.rest._pull = try! Pack(Data(contentsOf: Bundle(for: TestPull.self).url(forResource: "fetch3", withExtension: nil)!))
                try! Data("hello world\n".utf8).write(to: self.file)
                repository.commit([self.file], message: "Add file not tracked in the list.") {
                    let external = try! Hub.head.id(self.url)
                    XCTAssertTrue(try! FileManager.default.contentsOfDirectory(atPath: self.url.path).contains("myfile.txt"))
                    repository.pull {
                        let commit = try! Hub.head.commit(self.url)
                        let contents = try! FileManager.default.contentsOfDirectory(atPath: self.url.path)
                        XCTAssertTrue(contents.contains("myfile.txt"))
                        XCTAssertTrue(contents.contains("asd.txt"))
                        XCTAssertEqual(7, contents.count)
                        XCTAssertEqual(2, commit.parent.count)
                        XCTAssertEqual("4ec6903ca199e0e92c6cd3abb5b95f3b7f3d7e4d", commit.parent.last)
                        XCTAssertEqual(external, commit.parent.first)
                        XCTAssertTrue(repository.state.list.isEmpty)
                        XCTAssertEqual("4ec6903ca199e0e92c6cd3abb5b95f3b7f3d7e4d", String(decoding:
                            (try? Data(contentsOf: self.url.appendingPathComponent(".git/refs/remotes/origin/master"))) ?? Data(), as: UTF8.self))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
