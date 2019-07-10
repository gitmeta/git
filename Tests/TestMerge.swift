import XCTest
@testable import Git

class TestMerge: XCTestCase {
    private var url: URL!
    private var rest: MockRest!
    
    override func setUp() {
        rest = MockRest()
        Hub.session = Session()
        Hub.factory.rest = MockRest()
        Hub.factory.rest = rest
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        Hub.session.name = "hello"
        Hub.session.email = "world"
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: url)
    }
    
    func testMerging() {
        let expect = expectation(description: "")
        var repository: Repository!
        Hub.create(url) {
            repository = $0
            let file1 = self.url.appendingPathComponent("file1.txt")
            try! Data("hello world\n".utf8).write(to: file1)
            repository.commit([file1], message: "First commit.\n") {
                let first = try! Hub.head.id(self.url)
                let file2 = self.url.appendingPathComponent("file2.txt")
                try! Data("lorem ipsum\n".utf8).write(to: file2)
                repository.commit([file2], message: "Second commit.\n") {
                    let second = try! Hub.head.id(self.url)
                    try? repository.stage.merge(first)
                    let merged = try! Hub.head.commit(self.url)
                    XCTAssertEqual(second, merged.parent.first)
                    XCTAssertEqual(first, merged.parent.last)
                    XCTAssertEqual("Merge.\n", merged.message)
                    XCTAssertEqual(3, try? History(self.url).result.count)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSynch() {
        let expect = expectation(description: "")
        var repository: Repository!
        let fetch = Fetch()
        fetch.branch.append("335a33ae387dc24f057852fdb92e5abc71bf6b85")
        rest._fetch = fetch
        rest._pull = try? Pack(Data(contentsOf: Bundle(for: TestPull.self).url(forResource: "fetch2", withExtension: nil)!))
        Hub.create(url) {
            repository = $0
            try? Config("lorem ipsum").save(self.url)
            repository.pull {
                let file = self.url.appendingPathComponent("control.txt")
                try! Data("hello world\n".utf8).write(to: file)
                repository.commit([file], message: "First commit") {
                    repository.pull {
                        repository.push {
                            XCTAssertEqual(Hub.head.origin(self.url)!, try? Hub.head.id(self.url))
                            expect.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
}
