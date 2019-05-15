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
            
            switch category {
            case .deltaRef:
                debugPrint(try parse.hash())
            case .deltaOfs:
                parse.discard(2)
                print("expected \(expected)")
            default: break
            }
            
            let content = Hub.press.unpack(expected, data: parse.data.subdata(in: parse.index ..< parse.data.count))
            parse.discard(content.0)
            /*var index = parse.index + 1
            var content = Data()
//            print(category)
            while content.count < expected {
                index += 1
                content = Hub.press.decompress(parse.data.subdata(in: parse.index ..< index))
            }*/
            print(category)
            items.append((category, content.1))
            /*
//            print(String(decoding: content, as: UTF8.self))
            parse.discard(index - parse.index)
            
            if String(decoding: parse.data.subdata(in: parse.index ..< parse.index + 1), as: UTF8.self) == "\u{0000}" {
                
                print(":::::::::::::::::::::::::: clean \(parse.index) : \(content.count) : \(expected)")
                parse.discard(1)
            } else {
                print(":::::::::::::::::::::::::: no clean :::: \(parse.index) : \(content.count) : \(expected)")
            }
            
            if parse.index == 4396 {
                parse.discard(-1)
                let adler = Hub.press.adler32(content)
                
                debugPrint("\(try parse.byte()) \(try parse.byte()) \(try parse.byte()) \(try parse.byte())")
                
                debugPrint("\(adler[0]) \(adler[1]) \(adler[2]) \(adler[3])")
                fatalError()
            }
//            parse.discard(4)
            debugPrint("\(try parse.byte()) \(try parse.byte()) \(try parse.byte()) \(try parse.byte())")*/
        }
        guard parse.data.count - parse.index == 20 else { throw Failure.Pack.invalidPack }
    }
}
