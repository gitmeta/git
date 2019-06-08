import XCTest
@testable import Git

class TestFetch: XCTestCase {
    func testPull() {
        let fetch = try? Fetch.Pull(try! Data(contentsOf: Bundle(for: TestFetch.self).url(forResource: "fetchPull0", withExtension: nil)!))
        XCTAssertNotNil(fetch)
        XCTAssertEqual(1, fetch?.branch.count)
        XCTAssertEqual("54cac1e1086e2709a52d7d1727526b14efec3a77", fetch?.branch.first)
    }
    
    func testPush() {
        let fetch = try? Fetch.Push(try! Data(contentsOf: Bundle(for: TestFetch.self).url(forResource: "fetchPush0", withExtension: nil)!))
        XCTAssertNotNil(fetch)
        XCTAssertEqual(1, fetch?.branch.count)
        XCTAssertEqual("21641afd04cd878a8e5d0275d25524499805569d", fetch?.branch.first)
    }
}
