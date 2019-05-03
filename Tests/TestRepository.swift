import XCTest
@testable import Git

class TestRepository: XCTestCase {
    override func setUp() {
        Git.session = Session()
    }
    
    func testRefresh() {
        let repository = Repository(URL(fileURLWithPath: ""))
        repository.state.last = Date()
        repository.refresh()
        XCTAssertEqual(Date.distantPast, repository.state.last)
    }
}
