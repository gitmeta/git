import XCTest
@testable import Git

class TestParse: XCTestCase {
    func testParseBits0() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(0)) { $0 })).bits()
        XCTAssertFalse(bits[0])
        XCTAssertFalse(bits[1])
        XCTAssertFalse(bits[2])
        XCTAssertFalse(bits[3])
    }
    
    func testParseBits1() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(1)) { $0 })).bits()
        XCTAssertFalse(bits[0])
        XCTAssertFalse(bits[1])
        XCTAssertFalse(bits[2])
        XCTAssertTrue(bits[3])
    }
    
    func testParseBits2() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(2)) { $0 })).bits()
        XCTAssertFalse(bits[0])
        XCTAssertFalse(bits[1])
        XCTAssertTrue(bits[2])
        XCTAssertFalse(bits[3])
    }
    
    func testParseBits3() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(3)) { $0 })).bits()
        XCTAssertFalse(bits[0])
        XCTAssertFalse(bits[1])
        XCTAssertTrue(bits[2])
        XCTAssertTrue(bits[3])
    }
    
    func testParseBits7() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(7)) { $0 })).bits()
        XCTAssertFalse(bits[0])
        XCTAssertTrue(bits[1])
        XCTAssertTrue(bits[2])
        XCTAssertTrue(bits[3])
    }
    
    func testParseBits8() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(8)) { $0 })).bits()
        XCTAssertTrue(bits[0])
        XCTAssertFalse(bits[1])
        XCTAssertFalse(bits[2])
        XCTAssertFalse(bits[3])
    }
    
    func testParseBits15() {
        let bits = try! Parse(Data(withUnsafeBytes(of: UInt8(15)) { $0 })).bits()
        XCTAssertTrue(bits[0])
        XCTAssertTrue(bits[1])
        XCTAssertTrue(bits[2])
        XCTAssertTrue(bits[3])
    }
}
