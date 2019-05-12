import XCTest
@testable import Git

class TestFetch: XCTestCase {
    override func setUp() {
        Hub.session = Session()
        Hub.rest = MockRest()
    }
    
    func testAdv0() {
        let fetch = try? Fetch.Adv(try! Data(contentsOf:
            Bundle(for: TestFetch.self).url(forResource: "fetchAdv0", withExtension: nil)!))
        XCTAssertNotNil(fetch)
        XCTAssertEqual(1, fetch?.refs.count)
        XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", fetch?.refs.first)
    }
}
