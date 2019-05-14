import Foundation

class Pack {
    enum Category: Int {
        case commit = 1
        case tree = 2
        case blob = 3
        case tag = 4
        case reserved = 5
        case deltaOfs = 6
        case deltaRef = 7
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
    
    private(set) var items = [(Category, Data)]()
    
    convenience init(_ url: URL, id: String) throws {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
        else { throw Failure.Pack.packNotFound }
        try self.init([0,0,0,0,0,0,0,0] + data)
    }
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        parse.discard(8)
        guard try parse.string() == "PACK" else { throw Failure.Pack.invalidPack }
        parse.discard(4)
        try (0 ..< (try parse.number())).forEach { _ in
            var byte = Int(try parse.byte())
            guard let category = Category(rawValue: (byte >> 4) & 7) else { throw Failure.Pack.object }
            var expected = byte & 15
            var shift = 4
            while byte & Int(0x80) == 128 {
                byte = Int(try parse.byte())
                expected += (byte & 0x7f) << shift
                shift += 7
            }
            var index = parse.index + 1
            var content = Data()
            print(category)
            while content.count < expected {
                index += 1
                content = Hub.press.decompress(parse.data.subdata(in: parse.index ..< index))
            }
            items.append((category, content))
            print(String(decoding: content, as: UTF8.self))
            parse.discard((index - parse.index) + (index % 2 == 0 ? 4 : 5))
        }
    }
}
