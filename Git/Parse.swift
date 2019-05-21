import Foundation

class Parse {
    let data: Data
    private(set) var index = 0
    
    init?(_ url: URL) {
        if let data = try? Data(contentsOf: url) {
            self.data = data
        } else {
            return nil
        }
    }
    
    init(_ data: Data) {
        self.data = data
    }
    
    func ascii(_ limiter: String) throws -> String {
        var result = ""
        var character = ""
        while character != limiter {
            result += character
            character = try self.character()
        }
        return result
    }
    
    func variable() throws -> String {
        var result = ""
        var byte = ""
        repeat {
            result += byte
            byte = try character()
        } while byte != "\u{0000}"
        return result
    }
    
    func name() throws -> String {
        return try {
            discard($0 ? 4 : 2)
            let result = String(decoding: try advance($1), as: UTF8.self)
            clean()
            return result
        } (try not2(), try length())
    }
    
    func discard(_ until: String) throws {
        while String(decoding: try advance(until.count), as: UTF8.self) != until {
            index -= until.count - 1
        }
    }
    
    func byte() throws -> UInt8 { return try advance(1).first! }
    func string() throws -> String { return String(decoding: try advance(4), as: UTF8.self) }
    func character() throws -> String { return String(decoding: try advance(1), as: UTF8.self) }
    func hash() throws -> String { return (try advance(20)).map { String(format: "%02hhx", $0) }.joined() }
    func skipExtensions() { discard((data.count - 20) - index) }
    func decompress(_ amount: Int) throws -> Data { return Hub.press.decompress(try advance(amount)) }
    func discard(_ bytes: Int) { index += bytes }
    
    func number() throws -> Int {
        if let result = Int(try advance(4).map { String(format: "%02hhx", $0) }.joined(), radix: 16) {
            return result
        }
        throw Failure.Parsing.malformed
    }
    
    func date() throws -> Date {
        let result = Date(timeIntervalSince1970: TimeInterval(try number()))
        discard(4)
        return result
    }
    
    func conflict() throws -> Bool {
        var byte = data.subdata(in: index ..< index + 1).first!
        byte >>= 2
        if (byte & 0x01) == 1 {
            return true
        }
        byte >>= 1
        if (byte & 0x01) == 1 {
            return true
        }
        return false
    }
    
    func size(_ carry: Int = 0, shift: Int = 0) throws -> Int {
        var byte = 0
        var result = carry
        var shift = shift
        repeat {
            byte = Int(try self.byte())
            result += (byte & 0x7f) << shift
            shift += 7
        } while byte >= 128
        return result
    }
    
    func offset() throws -> Int {
        var byte = 0
        var result = 0
        var times = 0
        repeat {
            byte = Int(try self.byte())
            result <<= times * 7
            result += (byte & 0x7f)
            if times >= 1 {
                result += Int(pow(2, (7 * Double(times))))
            }
            times += 1
        } while byte >= 128
        return result
    }
    
    func advance(_ bytes: Int) throws -> Data {
        let index = self.index + bytes
        guard data.count >= index else { throw Failure.Parsing.malformed }
        let result = data.subdata(in: self.index ..< index)
        self.index = index
        return result
    }
    
    private func clean() {
        while (String(decoding: data.subdata(in: index ..< index + 1), as: UTF8.self) == "\u{0000}") { discard(1) }
    }
    
    private func not2() throws -> Bool {
        var byte = data.subdata(in:
            index ..< index + 1).withUnsafeBytes { $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).pointee }
        byte >>= 1
        return (byte & 0x01) == 1
    }
    
    private func length() throws -> Int {
        guard let result = Int(data.subdata(in: index + 1 ..< index + 2).map { String(format: "%02hhx", $0) }.joined(),
                               radix: 16) else { throw Failure.Parsing.malformed }
        return result
    }
}
