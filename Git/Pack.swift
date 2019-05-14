import Foundation

class Pack {
    enum Category: Substring {
        case commit = "001"
        case tree = "010"
        case blob = "011"
        case tag = "100"
        case reserved = "101"
        case deltaOfs = "110"
        case deltaRef = "111"
    }
    
    class Index {
        private(set) var version = 2
        private(set) var entries = [(String, String, Int)]()
        
        init(_ url: URL, id: String) throws {
            guard let parse = Parse(url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
            else { throw Failure.Pack.indexNotFound }
            guard
                try parse.byte() == 255,
                try parse.byte() == 116,
                try parse.byte() == 79,
                try parse.byte() == 99
                else { throw Failure.Pack.invalidIndex }
            version = try parse.number()
            parse.discard(1020)
            let count = try parse.number()
            try (0 ..< count).forEach { _ in
                entries.append((try parse.hash(), "", 0))
            }
            try (0 ..< count).forEach {
                entries[$0].1 = try parse.crc()
            }
            try (0 ..< count).forEach {
                entries[$0].2 = try parse.number()
            }
        }
    }
    
    class func load(_ url: URL) -> [Index] {
        var result = [Index]()
        try? FileManager.default.contentsOfDirectory(at:
            url.appendingPathComponent(".git/objects/pack"), includingPropertiesForKeys: nil).forEach {
                if $0.lastPathComponent.hasSuffix(".idx"),
                    let pack = try? Index(url, id: String($0.lastPathComponent.dropFirst(5).dropLast(4))) {
                    result.append(pack)
                }
        }
        return result
    }
    
    init(_ url: URL, id: String) throws {
        guard let parse = Parse(url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
        else { throw Failure.Pack.packNotFound }
        guard try parse.string() == "PACK" else { throw Failure.Pack.invalidPack }
        parse.discard(4)
        try (0 ..< (try parse.number())).forEach { _ in
            
            
            
            
            
            var byte = try parse.bits()
            print("\n\n\n")
            print("original \(byte)")
            byte.removeFirst()
            guard let category = Category(rawValue: byte.prefix(3)) else { throw Failure.Pack.object }
            byte.removeFirst(3)
            var more = byte.last == "1"
            byte.removeLast()
            var size = byte
            while more {
                byte = try parse.bits()
                print("more: \(byte)")
                more = byte.last == "1"
                byte.removeLast()
//                while byte.first == "0" {
//                    byte.removeFirst()
//                }
                size = byte + size
                more = false
            }
            let count = Int(String(size.reversed()), radix: 2)!
            
            print(category)
            if category == .deltaOfs {
                
                var byte = ""
                var size = ""
                repeat {
                    byte = try parse.bits()
                    size += byte.suffix(7)
                } while(byte.first == "1")
                let count2 = Int(size, radix: 2)!
                print("inversed \(count2)")
//                print("file \(count) nulled count: \(try parse.nulled())")
                
            } else {
//                let commit = try Commit(try parse.decompress(count))
//                print(commit)
                
            }
//            parse.discard(count)
            
            print("data size: \(parse.data.count) index: \(parse.index)")
            print("file \(count) ")
            if category == .deltaRef { print(try parse.hash()) }
            let decompressed = try parse.decompress(count - 4)
            debugPrint(String(decoding: decompressed, as: UTF8.self))
            debugPrint(try parse.byte())
            debugPrint(try parse.byte())
            debugPrint(try parse.byte())
            debugPrint(try parse.byte())
        }
    }
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        parse.discard(8)
        guard try parse.string() == "PACK" else { throw Failure.Pack.invalidPack }
        parse.discard(4)
        try (0 ..< (try parse.number())).forEach { _ in
            
            
            var x = UInt(try parse.byte())
            print((x >> 4) & 7)
            var s = x & 15
            var shift = 4
            while x & UInt(0x80) == 128 {
                x = UInt(try parse.byte())
//                x = x << 1
                s += (x & 0x7f) << shift
//                s = (s << shift) | (x & 0x7f)
                shift += 7
            }
            
            print(s)
            return;
            //
            //            type = (c >> 4) & 7;
            //            size = (c & 15);
            //            shift = 4;
            //            while (c & 0x80) {
            //                pack = fill(1);
            //                c = *pack;
            //                use(1);
            //                size += (c & 0x7f) << shift;
            //                shift += 7;
            //            }
            
            
            
            
            
            var byte = try parse.bits()
            print("\n\n\n")
            print("original \(byte)")
            byte.removeFirst()
            guard let category = Category(rawValue: byte.prefix(3)) else { throw Failure.Pack.object }
            byte.removeFirst(3)
            var more = byte.last == "1"
            byte.removeLast()
            var size = byte
            while more {
                byte = try parse.bits()
                print("more: \(byte)")
                more = byte.last == "1"
                byte.removeLast()
                //                while byte.first == "0" {
                //                    byte.removeFirst()
                //                }
                size = byte + size
                more = false
            }
            let count = Int(String(size.reversed()), radix: 2)!
            
            print(category)
            if category == .deltaOfs {
                
                var byte = ""
                var size = ""
                repeat {
                    byte = try parse.bits()
                    size += byte.suffix(7)
                } while(byte.first == "1")
                let count2 = Int(size, radix: 2)!
                print("inversed \(count2)")
                //                print("file \(count) nulled count: \(try parse.nulled())")
                
            } else {
                //                let commit = try Commit(try parse.decompress(count))
                //                print(commit)
                
            }
            //            parse.discard(count)
            
            print("data size: \(parse.data.count) index: \(parse.index)")
            print("file \(count) ")
            if category == .deltaRef { print(try parse.hash()) }
            let decompressed = try parse.decompress(category == .commit ? 500 : 45)
            debugPrint(String(decoding: decompressed, as: UTF8.self))
//            debugPrint(try parse.character())
//            debugPrint(try parse.character())
//            debugPrint(try parse.character())
            debugPrint(try parse.crc())
        }
    }
}
