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
    private(set) var commits = [String: Commit]()
    private(set) var trees = [String: Tree]()
    private(set) var blobs = [String: Data]()
    private(set) var tags = [String]()
    
    convenience init(_ url: URL, id: String) throws {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
        else { throw Failure.Pack.packNotFound }
        try self.init(data)
    }
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        try parse.discard("PACK")
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
            
            var ref = ""
            if category == .deltaRef { ref = try parse.hash() }
            let content = Hub.press.unpack(expected, data: parse.data.subdata(in: parse.index ..< parse.data.count))
            parse.discard(content.0)
            
            switch category {
            case .commit: try commit(content.1)
            case .tree: try tree(content.1)
            case .blob: blob(content.1)
            case .tag: tag(content.1)
            case .deltaRef: delta(content.1, ref: ref)
            case .deltaOfs: delta(content.1, ofs: 0)
            case .reserved: throw Failure.Pack.invalidPack
            }
        }
        guard parse.data.count - parse.index == 20 else { throw Failure.Pack.invalidPack }
    }
    
    private func commit(_ data: Data) throws {
        let commit = try Commit(data)
        commits[Hub.hash.commit(commit.serial).1] = commit
    }
    
    private func tree(_ data: Data) throws {
        trees[Hub.hash.tree(data).1] = try Tree(data)
    }
    
    private func blob(_ data: Data) {
        blobs[Hub.hash.blob(data).1] = data
    }
    
    private func tag(_ data: Data) {
        tags.append(String(decoding: data, as: UTF8.self))
    }
    
    private func delta(_ data: Data, ref: String) {
        print("ref: \(ref)")
        print("data: \(data.count)")
    }
    
    private func delta(_ data: Data, ofs: Int) {
        
    }
}
