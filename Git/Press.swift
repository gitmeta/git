import Foundation
import Compression

class Press {
    func decompress(_ data: Data) -> Data {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        debugPrint(Int(data.subdata(in: 0 ..< 1).map { String(format: "%02hhx", $0) }.joined(), radix: 16))
        debugPrint(Int(data.subdata(in: 1 ..< 2).map { String(format: "%02hhx", $0) }.joined(), radix: 16))
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
//        var data = Data()
//        withUnsafeBytes(of: UInt8(120)) { data.append(contentsOf: $0) }
//        withUnsafeBytes(of: UInt8(1)) { data.append(contentsOf: $0) }
//        data.append(try! Data(contentsOf: url))
        let data = try! Data(contentsOf: url)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.withUnsafeBytes {
            let wrote = compression_encode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  data.count, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count: wrote)
        } as Data
        buffer.deallocate()
        return result
    }
}
