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
        struct Entry {
            fileprivate(set) var id = ""
            fileprivate(set) var offset = 0
        }
        
        private(set) var entries = [Entry]()
        
        init(_ url: URL, id: String) throws {
            guard let parse = Parse(url.appendingPathComponent(".git/objects/pack/pack-\(id).idx")) else { throw Failure.Pack.indexNotFound }
            guard
                try parse.byte() == 255,
                try parse.byte() == 116,
                try parse.byte() == 79,
                try parse.byte() == 99
            else { throw Failure.Pack.invalidIndex }
            parse.discard(1024)
            let count = try parse.number()
            try (0 ..< count).forEach { _ in
                var entry = Entry()
                entry.id = try parse.hash()
                entries.append(entry)
            }
            parse.discard(4 * count)
            try (0 ..< count).forEach {
                entries[$0].offset = try parse.number()
            }
        }
    }
    
    class func index(_ url: URL) throws -> [Index] {
        var result = [Index]()
        if FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack").path) {
            try FileManager.default.contentsOfDirectory(at:
                url.appendingPathComponent(".git/objects/pack"), includingPropertiesForKeys: nil).forEach {
                    if $0.lastPathComponent.hasSuffix(".idx") {
                        result.append(try Index(url, id: String($0.lastPathComponent.dropFirst(5).dropLast(4))))
                    }
            }
        }
        return result
    }
    
    class func pack(_ url: URL) throws -> [String: Pack] {
        var result = [String: Pack]()
        if FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack").path) {
            try FileManager.default.contentsOfDirectory(at:
                url.appendingPathComponent(".git/objects/pack"), includingPropertiesForKeys: nil).forEach {
                    if $0.lastPathComponent.hasSuffix(".pack") {
                        let id = String($0.lastPathComponent.dropFirst(5).dropLast(5))
                        result[id] = try Pack(url, id: id)
                    }
            }
        }
        return result
    }
    
    private(set) var commits = [String: (Commit, Int, Data)]()
    private(set) var trees = [String: (Tree, Int, Data)]()
    private(set) var blobs = [String: (Int, Data)]()
    private(set) var tags = [String]()
    private var deltas = [(String, Data, Int)]()
    private var offsets = [(Int, Data, Int)]()
    
    convenience init(_ url: URL, id: String) throws {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
        else { throw Failure.Pack.packNotFound }
        try self.init(data)
    }
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        try parse.discard("PACK")
        parse.discard(4)
        let count = try parse.number()
        try (0 ..< count).forEach { _ in
            let index = parse.index
            let byte = Int(try parse.byte())
            guard let category = Category(rawValue: (byte >> 4) & 7) else { throw Failure.Pack.object }
            
            var expected = byte & 15
            if byte >= 128 {
                expected = try parse.size(expected, shift: 4)
            }
            
            var ref = ""
            var ofs = 0

            switch category {
            case .deltaRef: ref = try parse.hash()
            case .deltaOfs: ofs = index - (try parse.offset())
            default: break
            }

            let content = try Hub.press.unpack(expected, data: parse.data.subdata(in: parse.index ..< parse.data.count))
            parse.discard(content.0)
            
            switch category {
            case .commit: try commit(content.1, index: index)
            case .tree: try tree(content.1, index: index)
            case .blob: blob(content.1, index: index)
            case .tag: tag(content.1)
            case .deltaRef: deltas.append((ref, content.1, index))
            case .deltaOfs: offsets.append((ofs, content.1, index))
            case .reserved: throw Failure.Pack.invalidPack
            }
        }
        guard parse.data.count - parse.index == 20 else {
            throw Failure.Pack.invalidPack
        }
        try deltas.forEach {
            try delta($0.0, data: $0.1, index: $0.2)
        }
        try offsets.forEach {
            try delta($0.0, data: $0.1, index: $0.2)
        }
    }
    
    func unpack(_ url: URL) throws {
        try commits.forEach {
            try Hub.content.add($0.1.0, url: url)
        }
        try trees.forEach {
            try Hub.content.add($0.1.0, url: url)
        }
        try blobs.forEach {
            try Hub.content.add($0.1.1, url: url)
        }
    }
    
    func remove(_ url: URL, id: String) throws {
        try FileManager.default.removeItem(at: url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
        try FileManager.default.removeItem(at: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack"))
    }
    
    private func commit(_ data: Data, index: Int) throws {
        let commit = try Commit(data)
        commits[Hub.hash.commit(commit.serial).1] = (commit, index, data)
    }
    
    private func tree(_ data: Data, index: Int) throws {
        trees[Hub.hash.tree(data).1] = (try Tree(data), index, data)
    }
    
    private func blob(_ data: Data, index: Int) {
        blobs[Hub.hash.blob(data).1] = (index, data)
    }
    
    private func tag(_ data: Data) {
        tags.append(String(decoding: data, as: UTF8.self))
    }
    
    private func delta(_ ref: String, data: Data, index: Int) throws {
        if let commit = commits.first(where: { $0.0 == ref })?.1.2 {
            try delta(.commit, base: commit, data: data, index: index)
        } else if let tree = trees.first(where: { $0.0 == ref })?.1.2 {
            try delta(.tree, base: tree, data: data, index: index)
        } else if let blob = blobs.first(where: { $0.0 == ref })?.1.1 {
            try delta(.blob, base: blob, data: data, index: index)
        } else {
            throw Failure.Pack.invalidDelta
        }
    }
    
    private func delta(_ ofs: Int, data: Data, index: Int) throws {
        if let commit = commits.first(where: { $0.1.1 == ofs })?.1.2 {
            try delta(.commit, base: commit, data: data, index: index)
        } else if let tree = trees.first(where: { $0.1.1 == ofs })?.1.2 {
            try delta(.tree, base: tree, data: data, index: index)
        } else if let blob = blobs.first(where: { $0.1.0 == ofs })?.1.1 {
            try delta(.blob, base: blob, data: data, index: index)
        } else {
            throw Failure.Pack.invalidDelta
        }
    }
    
    private func delta(_ category: Category, base: Data, data: Data, index: Int) throws {
        let parse = Parse(data)
        var result = Data()
        guard try parse.size() == base.count else { throw Failure.Pack.invalidDelta }
        let expected = try parse.size()
        while parse.index < data.count {
            let byte = Int(try parse.byte())
            if byte >= 128 {
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
                if size == 0 { size = 65536 }
                result += base.subdata(in: offset ..< offset + size)
            } else {
                result += try parse.advance(byte)
            }
        }
        guard result.count == expected else { throw Failure.Pack.invalidDelta }
        switch category {
        case .commit: try commit(result, index: index)
        case .tree: try tree(result, index: index)
        case .blob: blob(result, index: index)
        default: throw Failure.Pack.invalidDelta
        }
    }
}
