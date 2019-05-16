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
    
    private(set) var commits = [String: (Commit, Data)]()
    private(set) var trees = [String: (Tree, Data)]()
    private(set) var blobs = [String: Data]()
    private(set) var tags = [String]()
    private var deltas = [(String, Data)]()
    
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
            let byte = Int(try parse.byte())
            guard let category = Category(rawValue: (byte >> 4) & 7) else { throw Failure.Pack.object }
            var expected = byte & 15
            if byte & 0x80 == 128 {
                expected = try parse.size(expected, shift: 4)
            }
            
            var ref = ""
            var ofs = 0

            switch category {
            case .deltaRef:
                ref = try parse.hash()
            case .deltaOfs:
//                let byte = Int(try parse.byte())
//                ofs = byte & 15
//                if byte & 0x80 == 128 {
//                    ofs = try parse.size(ofs, shift: 4)
//                }
                break
            default: break
            }
 
            let content = Hub.press.unpack(expected, data: parse.data.subdata(in: parse.index ..< parse.data.count))
            parse.discard(content.0)
            
            switch category {
            case .commit: try commit(content.1)
            case .tree: try tree(content.1)
            case .blob: blob(content.1)
            case .tag: tag(content.1)
            case .deltaRef:
                deltas.append((ref, content.1))
            case .deltaOfs: delta(content.1, ofs: ofs)
            case .reserved: throw Failure.Pack.invalidPack
            }
        }
        try deltas.forEach {
            try delta($0.1, ref: $0.0)
        }
        guard parse.data.count - parse.index == 20 else { throw Failure.Pack.invalidPack }
    }
    
    private func commit(_ data: Data) throws {
        let commit = try Commit(data)
        commits[Hub.hash.commit(commit.serial).1] = (commit, data)
    }
    
    private func tree(_ data: Data) throws {
        trees[Hub.hash.tree(data).1] = (try Tree(data), data)
    }
    
    private func blob(_ data: Data) {
        blobs[Hub.hash.blob(data).1] = data
    }
    
    private func tag(_ data: Data) {
        tags.append(String(decoding: data, as: UTF8.self))
    }
    
    private func delta(_ data: Data, ref: String) throws {
        let parse = Parse(data)
        var result = Data()
        var category = Category.deltaRef
        let base = try {
            if let commit = commits.first(where: { $0.key == ref })?.1.1 {
                category = .commit
                return commit
            }
            if let tree = trees.first(where: { $0.key == ref })?.1.1 {
                category = .tree
                return tree
            }
            if let blob = blobs.first(where: { $0.key == ref })?.1 {
                category = .blob
                return blob
            }
            throw Failure.Pack.invalidDelta
        } () as Data
        guard try parse.size() == base.count else { throw Failure.Pack.invalidDelta }
        let expected = try parse.size()
        while parse.index < data.count {
            let byte = Int(try parse.byte())
            if byte & 0x80 == 128 {
                var offset = 0
                var shift = 0
                try (0 ..< 4).forEach {
                    offset += (byte >> $0) & 0x01 == 1 ? Int(try parse.byte()) << shift : 0
                    shift += 8
                }
                var size = 0
                shift = 0
                try (4 ..< 7).forEach {
                    size += (byte >> $0) & 0x01 == 1 ? Int(try parse.byte()) << shift : 0
                    shift += 8
                }
                result += base.subdata(in: offset ..< offset + size)
            } else {
                result += try parse.advance(byte)
            }
        }
        
        guard result.count == expected else { throw Failure.Pack.invalidDelta }
        switch category {
        case .commit: try commit(result)
        case .tree: try tree(result)
        case .blob: blob(result)
        default: throw Failure.Pack.invalidDelta
        }
    }
    
    private func delta(_ data: Data, ofs: Int) {
//        print(ofs)
      fatalError()
    }
}
