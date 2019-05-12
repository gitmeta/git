import XCTest
@testable import Git

class TestParse: XCTestCase {
    func testParseBits0() {
        XCTAssertEqual("00000000", try! Parse(Data(withUnsafeBytes(of: UInt8(0)) { $0 })).bits())
    }
    
    func testParseBits1() {
        XCTAssertEqual("00000001", try! Parse(Data(withUnsafeBytes(of: UInt8(1)) { $0 })).bits())
    }
    
    func testParseBits2() {
        XCTAssertEqual("00000010", try! Parse(Data(withUnsafeBytes(of: UInt8(2)) { $0 })).bits())
    }
    
    func testParseBits3() {
        XCTAssertEqual("00000011", try! Parse(Data(withUnsafeBytes(of: UInt8(3)) { $0 })).bits())
    }
    
    func testParseBits255() {
        XCTAssertEqual("11111111", try! Parse(Data(withUnsafeBytes(of: UInt8(255)) { $0 })).bits())
    }
}
