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
            return Data(bytes: buffer, count: wrote)
        } as Data
        
        buffer.deallocate()
        var data = Data([0x78, 0x1])
        data.append(result )
        
//        var adler = self.adler32().checksum.bigEndian
//        result.append(Data(bytes: &adler, count: MemoryLayout<UInt32>.size))
        
//        print("adler: \(adler32(result).bigEndian)")
//        data.append(contentsOf: "\u{01}\0\u{1A}\u{0B}\u{04}]".utf8)
        var adler = adler32(source).bigEndian
        print("adler: \(adler)")
        data.append(Data(bytes: &adler, count: MemoryLayout<UInt32>.size))
        
        
        //"\u{01}\0\u{1A}\u{0B}\u{04}]"
        
        print("result \(data.count)")
        return data
    }
    
    private func adler32(_ data: Data) -> UInt32 {
        var s1: UInt32 = 1 & 0xffff
        var s2: UInt32 = (1 >> 16) & 0xffff
        let prime: UInt32 = 65521
        
        for byte in data {
            s1 += UInt32(byte)
            if s1 >= prime { s1 = s1 % prime }
            s2 += s1
            if s2 >= prime { s2 = s2 % prime }
        }
        return (s2 << 16) | s1
    }
}
