import XCTest
@testable import Git

class TestCommit: XCTestCase {
    private var url: URL!
    private var file: URL!
    
    override func setUp() {
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
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
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
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
        Git.create(url) { _ in
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", commit.save(self.url))
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
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
        Git.create(url) { _ in
            try! "ref: refs/heads/feature/test".write(to: self.url.appendingPathComponent(".git/HEAD"),
                                                      atomically: true, encoding: .utf8)
            XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", commit.save(self.url))
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
        commit.message = "Add project files."
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.parent = "dc0d3343fa24e912f08bc18aaa6f664a4a020079"
        Git.create(url) { _ in
            _ = commit.save(self.url)
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
            XCTAssertEqual(commit.message, String(loaded.message.dropLast()))
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
        Git.create(url) { _ in
            let id = commit.save(self.url)
            let loaded = try! Commit(Press().decompress(try! Data(contentsOf: self.url.appendingPathComponent(
                ".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))))
            XCTAssertEqual(commit.message, String(loaded.message.dropLast()))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLongAuthor() {
        let expect = expectation(description: "")
        let commit = Commit()
        commit.tree = "0d21e2f7f760f77ead2cb85cc128efb13f56401d"
        commit.author.name = "asdasdas asd sa das das dsa dsa das das das as dsa da"
        Git.create(url) { _ in
            let id = commit.save(self.url)
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
        let user = User()
        user.name = "hello"
        user.email = "world"
        DispatchQueue.global(qos: .background).async {
            repository.commit([], user: user, message: "hello world", error: { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            })
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptyMessage() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        let user = User()
        user.name = "hello"
        user.email = "world"
        repository.commit([file], user: user, message: "", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testNoCredentials() {
        let expect = expectation(description: "")
        let repository = Repository(url)
        repository.commit([file], user: User(), message: "hello world", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testFirstCommit() {
        let expect = expectation(description: "")
        Git.create(url) { repository in
            DispatchQueue.global(qos: .background).async {
                let user = User()
                user.name = "hello"
                user.email = "world"
                repository.commit([self.file], user: user, message: "hello world") {
                    XCTAssertEqual(Thread.main, Thread.current)
                    XCTAssertNotNil(repository.head)
                    XCTAssertNotNil(repository.headId)
                    XCTAssertEqual("hello", repository.head?.author.name)
                    XCTAssertEqual("world", repository.head?.author.email)
                    XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", repository.head?.tree)
                    XCTAssertEqual("hello world\n", repository.head?.message)
                    XCTAssertNil(repository.head?.parent)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAllowSecondCommitEmpty() {
        let expect = expectation(description: "")
        var repository: Repository!
        Git.create(url) {
            repository = $0
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([self.file], user: user, message: "hello world") {
                repository.commit([self.file], user: user, message: "second commit") {
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSecondCommitUpdate() {
        let expect = expectation(description: "")
        var repository: Repository!
        Git.create(url) {
            repository = $0
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([self.file], user: user, message: "hello world") {
                try! Data("lorem ipsum\n".utf8).write(to: self.file)
                repository.commit([self.file], user: user, message: "second commit") {
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
        let user = User()
        user.name = "hello"
        user.email = "world"
        repository.commit([URL(fileURLWithPath: "/")], user: user, message: "A failed commmit", error: { _ in
            expect.fulfill()
        })
        waitForExpectations(timeout: 1)
    }
    
    func testSecondCommit() {
        let expect = expectation(description: "")
        var repository: Repository!
        Git.create(url) {
            repository = $0
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([self.file], user: user, message: "hello world") {
                let headId = repository.headId!
                try! Data("modified\n".utf8).write(to: self.file)
                repository.commit([self.file], user: user, message: "second commit") {
                    XCTAssertEqual(headId, repository.head!.parent!)
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
        Git.create(url) { repository in
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([self.file, another], user: user, message: "hello world") {
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/01/a59b011a48660bb3828ec72b2b08990b8cf56b").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/12/b34e53d16df3d9f2dd6ad8a4c45af37e283dc1").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/48/1fe7479499b1b5623dfef963b5802d87af8c94").path))
                XCTAssertEqual("481fe7479499b1b5623dfef963b5802d87af8c94", repository.head?.tree)
                XCTAssertNotNil(repository.tree)
                XCTAssertEqual(2, repository.tree?.items.count)
                XCTAssertNotNil(repository.tree?.items.first(where: { $0 is Tree.Sub }))
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
        Git.create(url) {
            repository = $0
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([ignored], user: user, message: "hello world", error: { _ in
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
        Git.create(url) { repository in
            let user = User()
            user.name = "hello"
            user.email = "world"
            repository.commit([self.file], user: user, message: "hello world") {
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/84/b5f2f96994db6b67f8a0ee508b1ebb8b633c15").path))
                XCTAssertTrue(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/12/b34e53d16df3d9f2dd6ad8a4c45af37e283dc1").path))
                XCTAssertFalse(FileManager.default.fileExists(atPath: self.url.appendingPathComponent(
                    ".git/objects/48/1fe7479499b1b5623dfef963b5802d87af8c94").path))
                XCTAssertEqual("84b5f2f96994db6b67f8a0ee508b1ebb8b633c15", repository.head?.tree)
                XCTAssertNotNil(repository.tree)
                XCTAssertEqual(1, repository.tree?.items.count)
                XCTAssertNotNil(repository.tree?.items.first(where: { $0 is Tree.Blob }))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
}
