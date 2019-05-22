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
    
    func unpack(_ size: Int, data: Data) -> (Int, Data) {
        var index = 1
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
        
        stream.src_size = 0
        stream.dst_ptr = buffer
        stream.dst_size = size
        
        var result = Data()
        var source: Data?
        
        repeat {
            index += 1
            var flags = Int32(0)
            
            if stream.src_size == 0 {
                source = data.subdata(in: index ..< index + 1)
                stream.src_size = source!.count
//                flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                if source!.count < size {
//                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
            }
            
            if let source = source {
                let count = source.count
                source.withUnsafeBytes {
                    let a = count - stream.src_size
                    stream.src_ptr = $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1).advanced(by: a)
                    status = compression_stream_process(&stream, flags)
                }
            }
            
            switch status {
            case COMPRESSION_STATUS_OK,
                 COMPRESSION_STATUS_END:
                
                let count = size - stream.dst_size
                
                let outputData = Data(bytesNoCopy: buffer,
                                      count: count,
                                      deallocator: .none)
                
                // Write all produced bytes to the output file.
                result += outputData
                
                // Reset the stream to receive the next batch of output.
                stream.dst_ptr = buffer
                stream.dst_size = size
            case COMPRESSION_STATUS_ERROR:
                fatalError("COMPRESSION_STATUS_ERROR.")
                
                
            default:
                break
            }
            
        } while status == COMPRESSION_STATUS_OK
        
//        let adler = adler32(result)
//
//        print("jump::::::::::::::::::::::::::::::::::::::::::::::::                 ")
//        print("\(adler[0]) \(adler[1]) \(adler[2]) \(adler[3])")
//        while
//            data[index] != adler[0] &&
//            data[index + 1] != adler[1] &&
//            data[index + 2] != adler[2] &&
//            data[index + 3] != adler[3] {
//                print("+    \(data[index]) \(data[index + 1]) \(data[index + 2]) \(data[index + 3])")
//            index += 1
//        }
//
//
//
        index += 5
//

        //
//        print("nexts +    \(data[index]) \(data[index + 1]) \(data[index + 2]) \(data[index + 3])")
//        debugPrint(String(decoding: result, as: UTF8.self))
        return (index, result)
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
