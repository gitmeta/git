import Foundation
import Compression

class Press {
    private let size = 8_000_000
    private let prime = UInt32(65521)
    
    func decompress(_ data: Data) -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let result = data.subdata(in: 2 ..< data.count).withUnsafeBytes {
            let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                 data.count - 2, nil, COMPRESSION_ZLIB)
            return Data(bytes: buffer, count: read)
        } as Data
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
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let scratch = UnsafeMutablePointer<UInt8>.allocate(capacity: self.size)
        var result = Data()
        var index = 2
        while result.count < size {
            index += 1
            result = data.subdata(in: 2 ..< index).withUnsafeBytes {
                let read = compression_decode_buffer(buffer, size, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                                                     index - 2, scratch, COMPRESSION_ZLIB)
                return Data(bytes: buffer, count: read)
            } as Data
        }
        buffer.deallocate()
        scratch.deallocate()
        let adler = adler32(result)
        
        while
            data[index] != adler[0] &&
            data[index + 1] != adler[1] &&
            data[index + 2] != adler[2] &&
            data[index + 3] != adler[3] {
            index += 1
        }
        index += 4
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
