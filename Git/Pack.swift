import Foundation

class Pack {
    private(set) var version = 2
    private(set) var entries = [(String, String, Int)]()
    
    class func load(_ url: URL) -> [Pack] {
        var result = [Pack]()
        try? FileManager.default.contentsOfDirectory(at:
            url.appendingPathComponent(".git/objects/pack"), includingPropertiesForKeys: nil).forEach {
                if $0.lastPathComponent.hasSuffix(".idx"),
                    let pack = try? Pack(url, id: String($0.lastPathComponent.dropFirst(5).dropLast(4))) {
                    result.append(pack)
                }
        }
        return result
    }
    
    init(_ url: URL, id: String) throws {
        guard let parse = Parse(url.appendingPathComponent(".git/objects/pack/pack-\(id).idx"))
            else { throw Failure.Pack.indexNotFound }
        guard FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/pack/pack-\(id).pack").path)
            else { throw Failure.Pack.packNotFound }
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
