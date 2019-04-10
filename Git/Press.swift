import Foundation
import Compression

class Press {
    // header 7801
    func decompress(_ data: Data) -> Data {
        let size = 8_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes {
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count: read)
        } as Data
        buffer.deallocate()
        return result
    }
    
    func compress(_ url: URL) -> Data {
        let size = 8_000_000
        let string = String(decoding: try! Data(contentsOf: url), as: UTF8.self)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let wrote = compression_encode_buffer(buffer, size, Array(string.utf8), string.count, nil, COMPRESSION_ZLIB)
        let result = Data(bytes: buffer, count: wrote)
        buffer.deallocate()
        return result
    }
}
