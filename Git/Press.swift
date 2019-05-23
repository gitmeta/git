import Foundation
import Compression

class Press {
    private let size = 8_000_000
    private let prime = UInt32(65521)
    
    func decompress(_ data: Data) -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes { Data(bytes: buffer, count:
            compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), data.count - 2, nil, COMPRESSION_ZLIB))
        }
        buffer.deallocate()
        return result
    }
    
    func compress(_ source: Data) -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var data = Data([0x78, 0x1])
        data.append(source.withUnsafeBytes {
            let wrote = compression_encode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  source.count, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count: wrote)
        })
        data.append(adler32(source))
        buffer.deallocate()
        return data
    }
    
    func unpack(_ size: Int, data: Data) throws -> (Int, Data) {
        var index = lead(size, data: data) - 2
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var result = Data()
        data.withUnsafeBytes {
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
            stream.dst_ptr = buffer
            stream.dst_size = size
            stream.src_size = index
            stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: 2)
            status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
            result += Data(bytesNoCopy: buffer, count: size - stream.dst_size, deallocator: .none)
            while status == COMPRESSION_STATUS_OK {
                index += 1
                stream.dst_ptr = buffer
                stream.dst_size = size
                stream.src_size = 1
                stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: 1 + index)
                status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                result += Data(bytesNoCopy: buffer, count: size - stream.dst_size, deallocator: .none)
                print(result.count)
            }
        }
        index += 6
        buffer.deallocate()
        compression_stream_destroy(&stream)
        return (index, result)
    }
    
    private func lead(_ size: Int, data: Data) -> Int {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: max(size, self.size))
        let scratch = UnsafeMutablePointer<UInt8>.allocate(capacity: max(size, self.size))
        return data.withUnsafeBytes { Data(bytes: buffer, count: compression_decode_buffer( buffer, size, $0.baseAddress!.bindMemory(
            to: UInt8.self, capacity: 1).advanced(by: 2), data.count, scratch, COMPRESSION_ZLIB)) }.withUnsafeBytes { compression_encode_buffer(buffer, max(size, self.size), $0.baseAddress!.bindMemory(to: UInt8.self, capacity:
                1), size, scratch, COMPRESSION_ZLIB) }
    }
    
    private func decompress(_ data: Data, size: Int, buffer: UnsafeMutablePointer<UInt8>, scratch: UnsafeMutablePointer<UInt8>) -> Data {
        return data.withUnsafeBytes { Data(bytes: buffer, count: compression_decode_buffer(
            buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), data.count, scratch, COMPRESSION_ZLIB)) }
    }
    
    private func adler32(_ data: Data) -> Data {
        var s1 = UInt32(1 & 0xffff)
        var s2 = UInt32((1 >> 16) & 0xffff)
        data.forEach {
            s1 += UInt32($0)
            if s1 >= prime { s1 = s1 % prime }
            s2 += s1
            if s2 >= prime { s2 = s2 % prime }
        }
        var result = ((s2 << 16) | s1).bigEndian
        return Data(bytes: &result, count: MemoryLayout<UInt32>.size)
    }
}
