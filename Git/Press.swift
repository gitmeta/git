import Foundation
import Compression

class Press {
    private let prime = UInt32(65521)
    
    func decompress(_ data: Data) -> Data {
        return data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_decode_buffer(
                buffer, data.count * 10, $0.baseAddress!.bindMemory(
                    to: UInt8.self, capacity: 1).advanced(by: 2), data.count - 2, nil, COMPRESSION_ZLIB))
            buffer.deallocate()
            return result
        }
    }
    
    func compress(_ source: Data) -> Data {
        var data = Data([0x78, 0x1])
        data.append(source.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: source.count * 10)
            let wrote = compression_encode_buffer(buffer, source.count * 10, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                  source.count, nil, COMPRESSION_ZLIB)
            let result = Data(bytes: buffer, count: wrote)
            buffer.deallocate()
            return result
        })
        data.append(adler32(source))
        return data
    }
    
    func unpack(_ size: Int, data: Data) throws -> (Int, Data) {
        var index = max(compress(decompress(data)).count - max(size / 30, 9), 0)
        let result = try data.withUnsafeBytes {
            var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
            var advance = 2
            var read = index + 1
            var result = Data()
            repeat {
                index += 1
                stream.dst_ptr = buffer
                stream.dst_size = size
                stream.src_size = read
                stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: advance)
                status = compression_stream_process(&stream, 0)
                result += Data(bytes: buffer, count: size - stream.dst_size)
                read = 1
                advance = 2 + index
            } while status == COMPRESSION_STATUS_OK
            buffer.deallocate()
            compression_stream_destroy(&stream)
            guard status == COMPRESSION_STATUS_END else { throw Failure.Pack.read }
            guard result.count == size else { throw Failure.Pack.size }
            return result
        } as Data
        
        let adler = adler32(result)
        var found = false
        var drift = 0
        repeat {
            if drift > 3 { throw Failure.Pack.adler }
            if adler[0] == data[index + drift],
                adler[1] == data[index + drift + 1],
                adler[2] == data[index + drift + 2],
                adler[3] == data[index + drift + 3] {
                found = true
            }
            drift += 1
        } while !found
        
        index += 6
        return (index, result)
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
