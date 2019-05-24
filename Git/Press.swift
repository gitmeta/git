import Foundation
import Compression

class Press {
    private let size = 50_000_000
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
    /*
    func unpack(_ size: Int, data: Data) throws -> (Int, Data) {
        var index = 1
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var result = Data()
        data.withUnsafeBytes {
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
            repeat {
                index += 1
                stream.dst_ptr = buffer
                stream.dst_size = size
                stream.src_size = 1
                stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: index)
                status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
                result += Data(bytesNoCopy: buffer, count: size - stream.dst_size, deallocator: .none)
            } while status == COMPRESSION_STATUS_OK
        }
        
        guard result.count == size else {
            throw Failure.Pack.size
        }
        
        let adler = adler32(result)
        var found = false
        var drift = 0
        repeat {
            if drift > 7 {
                throw Failure.Pack.adler
            }
            if adler[0] == data[index + drift],
                adler[1] == data[index + drift + 1],
                adler[2] == data[index + drift + 2],
                adler[3] == data[index + drift + 3] {
                found = true
            }
            drift += 1
        } while !found
        
        index += 5
        buffer.deallocate()
        compression_stream_destroy(&stream)
        return (index, result)
    }*/
    
    func unpack(_ size: Int, data: Data) throws -> (Int, Data) {
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let scratch = UnsafeMutablePointer<UInt8>.allocate(capacity: max(size, self.size))
        
        var index = max(alead(size, data: data) - max(size / 50, 3), 0)
        
        
        /*var index = max(data.withUnsafeBytes {
            Data(bytesNoCopy: buffer, count: compression_decode_buffer( buffer, size, $0.baseAddress!.bindMemory(
                to: UInt8.self, capacity: 1).advanced(by: 2), data.count - 2, scratch, COMPRESSION_ZLIB), deallocator: .none)
        }.withUnsafeBytes {
            assert($0.count == size)
            return compression_encode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), size, scratch, COMPRESSION_ZLIB)
        } - 3, 0)*/
        let result = try data.withUnsafeBytes {
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
            var advance = 2
            var read = index + 1
            var result = Data()
            var times = 0
            print("read: \(read), advance: \(advance), index: \(index)")
            repeat {
                
                
                index += 1
                stream.dst_ptr = buffer
                stream.dst_size = size
                stream.src_size = read
                stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: advance)
                status = compression_stream_process(&stream, 0)
                result += Data(bytesNoCopy: buffer, count: size - stream.dst_size, deallocator: .none)
                read = 1
                advance = 2 + index
                times += 1
            } while status == COMPRESSION_STATUS_OK
//            print("stop \(data[index]) \(data[index + 1]) \(data[index + 2])")
            print("times \(times)")
            guard status == COMPRESSION_STATUS_END else {
                throw Failure.Pack.read
            }
            return result
        } as Data
        guard result.count == size else {
            throw Failure.Pack.size
        }
        
        let adler = adler32(result)
        var found = false
        var drift = 0
        repeat {
            if drift > 7 {
                throw Failure.Pack.adler
            }
            if adler[0] == data[index + drift],
                adler[1] == data[index + drift + 1],
                adler[2] == data[index + drift + 2],
                adler[3] == data[index + drift + 3] {
                found = true
            }
            drift += 1
        } while !found
        
        index += 6
        buffer.deallocate()
        scratch.deallocate()
        compression_stream_destroy(&stream)
        return (index, result)
    }
    
    func alead(_ size: Int, data: Data) -> Int {
        let decoded = decompress(data)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        let size = decoded.withUnsafeBytes {
            var status = compression_stream_init(&stream, COMPRESSION_STREAM_ENCODE, COMPRESSION_ZLIB)
            stream.dst_ptr = buffer
            stream.dst_size = size
            stream.src_size = decoded.count
            stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1)
            status = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))
            return size - stream.dst_size
        } as Int
        buffer.deallocate()
        compression_stream_destroy(&stream)
        return size
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
