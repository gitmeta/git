import Foundation

class Pack {
    enum Category: Substring {
        case commit = "001"
        case tree = "010"
        case blob = "011"
        case tag = "100"
        case reserverd = "101"
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
            var more = byte.first == "1"
            byte.removeFirst()
//            guard let category = Category(rawValue: byte.prefix(3)) else { throw Failure.Pack.object }
            let category = Category(rawValue: byte.prefix(3))
            if category == nil {
                print("auch")
            }
            byte.removeFirst(3)
            var size = byte
            while more {
                byte = try parse.bits()
                more = byte.first == "1"
                size += byte.suffix(7)
            }
            let count = Int(size, radix: 2)!
            print(category)
            print(count)
            print(parse.data.count)
            parse.variable()
            parse.discard(count)
        }
    }
}
