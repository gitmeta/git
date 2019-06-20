import XCTest
@testable import Git

class TestCommit: XCTestCase {
    private var url: URL!
    private var file: URL!
    
    override func setUp() {
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        file = url.appendingPathComponent("myfile.txt")
        try! Data("hello world\n".utf8).write(to: file)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testCreate() {
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = "-0500"
        commit.committer = commit.author
        commit.message = "Add project files.\n"
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent.append("dc0d3343fa24e912f08bc18aaa6f664a4a020079")
        XCTAssertEqual("""
tree 0d21e2f7f760f77ead2cb85cc128efb13f56401d
parent dc0d3343fa24e912f08bc18aaa6f664a4a020079
author Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500
committer Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500

Add project files.

""", commit.serial)
    }
    
    func testSave() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = "-0500"
        commit.committer = commit.author
        commit.message = "Add project files.\n"
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent.append("dc0d3343fa24e912f08bc18aaa6f664a4a020079")
        Hub.create(url) { _ in
            let id = try! Hub.content.add(commit, url: self.url)
            try? Hub.head.update(self.url, id: id)
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", id)
            let object = try? Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/51/92391e9f907eeb47aa38d1c6a3a4ea78e33564"))
            XCTAssertNotNil(object)
            XCTAssertEqual(173, object?.count)
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", String(
                decoding: try! Data(contentsOf: self.url.appendingPathComponent(".git/refs/heads/master")), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveBranch() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = "-0500"
        commit.committer = commit.author
        commit.message = "Add project files.\n"
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent.append("dc0d3343fa24e912f08bc18aaa6f664a4a020079")
        Hub.create(url) { _ in
            try! "ref: refs/heads/feature/test".write(to: self.url.appendingPathComponent(".git/HEAD"),
                                                      atomically: true, encoding: .utf8)
            let id = try! Hub.content.add(commit, url: self.url)
            try? Hub.head.update(self.url, id: id)
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", id)
            let object = try? Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/51/92391e9f907eeb47aa38d1c6a3a4ea78e33564"))
            XCTAssertNotNil(object)
            XCTAssertEqual(173, object?.count)
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", String(
                decoding: try! Data(contentsOf:
                    self.url.appendingPathComponent(".git/refs/heads/feature/test")), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testBackAndForth() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.author.name = "Jonathan Waldman"
        commit.author.email = "jonathan.waldman@live.com"
        commit.author.date = Date(timeIntervalSince1970: 1494296655)
        commit.author.timezone = "-0500"
        commit.committer = commit.author
        commit.message = "Add project files.\n"
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent.append("dc0d3343fa24e912f08bc18aaa6f664a4a020079")
        Hub.create(url) { _ in
            _ = try? Hub.content.add(commit, url: self.url)
            let loaded = try! Commit(Press().decompress(try! Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/51/92391e9f907eeb47aa38d1c6a3a4ea78e33564"))))
            XCTAssertEqual(commit.author.name, loaded.author.name)
            XCTAssertEqual(commit.author.email, loaded.author.email)
            XCTAssertEqual(commit.author.date, loaded.author.date)
            XCTAssertEqual(commit.author.timezone, loaded.author.timezone)
            XCTAssertEqual(commit.committer.name, loaded.committer.name)
            XCTAssertEqual(commit.committer.email, loaded.committer.email)
            XCTAssertEqual(commit.committer.date, loaded.committer.date)
            XCTAssertEqual(commit.committer.timezone, loaded.committer.timezone)
            XCTAssertEqual(commit.message, loaded.message)
            XCTAssertEqual(commit.tree, loaded.tree)
            XCTAssertEqual(commit.parent, loaded.parent)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testMessageMultiline() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.message = "Add project files.\n\n\n\n\n\ntest\ntest\ntest\n\n\ntest"
        Hub.create(url) { _ in
            let id = try! Hub.content.add(commit, url: self.url)
            let loaded = try! Commit(Press().decompress(try! Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))))
            XCTAssertEqual(commit.message, loaded.message)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLongAuthor() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.author.name = "asdasdas asd sa das das dsa dsa das das das as dsa da"
        Hub.create(url) { _ in
            let id = try! Hub.content.add(commit, url: self.url)
            let loaded = try! Commit(Press().decompress(try! Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))))
            XCTAssertEqual(commit.author.name, loaded.author.name)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptyList() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        Hub.session.name = "asd"
        Hub.session.email = "my@email.com"
        DispatchQueue.global(qos: .background).async {
            repository.commit([], message: "hello world", error: { _ in
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptyMessage() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        Hub.session.name = "asd"
        Hub.session.email = "my@email.com"
        repository.commit([file], message: "", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testNoCredentials() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        repository.commit([file], message: "hello world", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testInvalidUrl() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "hello"
            Hub.session.email = "world"
            repository.commit([self.url.appendingPathComponent("none.txt")], message: "hello world\n", error: { _ in expect.fulfill() })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFirstCommit() {
        let expect = expectation(description: "")
        let date = Date(timeIntervalSinceNow: -1)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            DispatchQueue.global(qos: .background).async {
                Hub.session.name = "hello"
                Hub.session.email = "world"
                repository.commit([self.file], message: "hello world\n") {
                    XCTAssertEqual(.main, Thread.current)
                    let commit = try? Hub.head.commit(self.url)
                    XCTAssertNotNil(commit)
                    XCTAssertNotNil(try? Hub.head.id(self.url))
                    XCTAssertEqual("hello", commit?.author.name)
                    XCTAssertEqual("world", commit?.author.email)
                    XCTAssertLessThan(date, commit!.author.date)
                    XCTAssertLessThan(date, commit!.committer.date)
                    XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", commit?.tree)
                    XCTAssertEqual("hello world\n", commit?.message)
                    XCTAssertNil(commit?.parent.first)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNotAllowedCommitEmpty() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([self.file], message: "hello world") {
                repository.commit([self.file], message: "second commit", error: { _ in
                    expect.fulfill()
                })
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSecondCommitUpdate() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([self.file], message: "hello world") {
                try! Data("lorem ipsum\n".utf8).write(to: self.file)
                repository.commit([self.file], message: "second commit") {
                    XCTAssertEqual(1, Index(self.url)?.entries.count)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testInvalidFile() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        Hub.session.name = "asd"
        Hub.session.email = "my@email.com"
        repository.commit([URL(fileURLWithPath: "/")], message: "A failed commmit", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testSecondCommit() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([self.file], message: "hello world") {
                let id = try! Hub.head.id(self.url)
                try! Data("modified\n".utf8).write(to: self.file)
                repository.commit([self.file], message: "second commit") {
                    XCTAssertEqual(id, (try? Hub.head.commit(self.url))?.parent.first!)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFirstCommitSubtree() {
        let expect = expectation(description: "")
        let abc = url.appendingPathComponent("abc")
        try! FileManager.default.createDirectory(at: abc, withIntermediateDirectories: true)
        let another = abc.appendingPathComponent("another.txt")
        try! Data("lorem ipsum\n".utf8).write(to: another)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([self.file, another], message: "hello world") {
                let tree = try? Hub.head.tree(self.url)
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/01/a59b011a48660bb3828ec72b2b08990b8cf56b").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/12/b34e53d16df3d9f2dd6ad8a4c45af37e283dc1").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/48/1fe7479499b1b5623dfef963b5802d87af8c94").path))
                XCTAssertEqual("481fe7479499b1b5623dfef963b5802d87af8c94", (try? Hub.head.commit(self.url))?.tree)
                XCTAssertNotNil(tree)
                XCTAssertEqual(2, tree?.items.count)
                XCTAssertNotNil(tree?.items.first(where: { $0.category == .tree }))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIgnoredFile() {
        let expect = expectation(description: "")
        try! """
not.js

""".write(to: url.appendingPathComponent(".gitignore"), atomically: true, encoding: .utf8)
        let ignored = url.appendingPathComponent("not.js")
        try! Data().write(to: ignored)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([ignored], message: "hello world", error: { _ in
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTreeIgnoredIfNotInCommit() {
        let expect = expectation(description: "")
        let abc = url.appendingPathComponent("abc")
        try! FileManager.default.createDirectory(at: abc, withIntermediateDirectories: true)
        let another = abc.appendingPathComponent("another.txt")
        try! Data("lorem ipsum\n".utf8).write(to: another)
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            Hub.session.name = "asd"
            Hub.session.email = "my@email.com"
            repository.commit([self.file], message: "hello world") {
                let tree = try? Hub.head.tree(self.url)
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/84/b5f2f96994db6b67f8a0ee508b1ebb8b633c15").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/12/b34e53d16df3d9f2dd6ad8a4c45af37e283dc1").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/48/1fe7479499b1b5623dfef963b5802d87af8c94").path))
                XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", (try? Hub.head.commit(self.url))?.tree)
                XCTAssertNotNil(tree)
                XCTAssertEqual(1, tree?.items.count)
                XCTAssertNotNil(tree?.items.first(where: { $0.category != .tree }))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
