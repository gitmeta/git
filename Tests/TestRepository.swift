import XCTest
@testable import Git

class TestRepository: XCTestCase {
    override func setUp() {
        Git.session = Session()
    }
    
    func testRefresh() {
        let repository = Repository(URL(fileURLWithPath: ""))
        repository.statuser.last = Date()
        repository.refresh()
        XCTAssertEqual(Date.distantPast, repository.statuser.last)
    }
}
