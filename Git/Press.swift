import Foundation
import Compression

class Press {
    func decompress(_ data: Data) -> Data {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        debugPrint(Int(data.subdata(in: 0 ..< 1).map { String(format: "%02hhx", $0) }.joined(), radix: 16))
        debugPrint(Int(data.subdata(in: 1 ..< 2).map { String(format: "%02hhx", $0) }.joined(), radix: 16))
        debugPrint(Int(data.subdata(in: data.count - 1 ..< data.count).map { String(format: "%02hhx", $0) }.joined(), radix: 16))
        debugPrint(String(decoding: data.subdata(in: data.count - 10 ..< data.count), as: UTF8.self))
        debugPrint(data.subdata(in: data.count - 10 ..< data.count).map { String(format: "%02hhx", $0) }.joined())
        debugPrint(data.count)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes {
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            print("read \(read)")
            return Data(bytes: buffer, count: read)
        } as Data
        buffer.deallocate()
        print(result.count)
        return result
    }
    
    func compress(_ url: URL) -> Data {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let source = try! Data(contentsOf: url)
        print("original \(source.count)")
        let result = source.withUnsafeBytes {
            let wrote = compression_encode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  source.count, nil, COMPRESSION_ZLIB)
            print("wrote \(wrote)")
            return Data(bytes: buffer, count: wrote + 2)
        } as Data
        
        buffer.deallocate()
        var data = Data()
        withUnsafeBytes(of: UInt8(120)) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: UInt8(1)) { data.append(contentsOf: $0) }
        data.append(result)
        data.append(contentsOf: "\u{01}\0\u{1A}\u{0B}\u{04}]".utf8)
        
        
        //"\u{01}\0\u{1A}\u{0B}\u{04}]"
        
        print("result \(data.count)")
        return data
    }
}
