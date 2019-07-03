import Foundation

final class Content {
    @discardableResult func add(_ commit: Commit, url: URL) throws -> String {
        return try {
            try add($0.1, data: $0.0, url: url)
            return $0.1
        } (Hub.hash.commit(commit.serial))
    }
    
    @discardableResult func add(_ tree: Tree, url: URL) throws -> String {
        return try {
            try add($0.1, data: $0.0, url: url)
            return $0.1
        } (Hub.hash.tree(tree.serial))
    }
    
    @discardableResult func add(_ file: URL, url: URL) throws -> String {
        return try {
            try add($0.1, data: $0.0, url: url)
            return $0.1
        } (Hub.hash.file(file))
    }
    
    @discardableResult func add(_ blob: Data, url: URL) throws -> String {
        return try {
            try add($0.1, data: $0.0, url: url)
            return $0.1
        } (Hub.hash.blob(blob))
    }
    
    func file(_ id: String, url: URL) throws -> Data {
        let parse = Parse(try Hub.content.get(id, url: url))
        _ = try parse.variable()
        return parse.data.subdata(in: parse.index ..< parse.data.count)
    }
    
    func get(_ id: String, url: URL) throws -> Data {
        return Hub.press.decompress(try Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))")))
    }
    
    func objects(_ url: URL) -> [String] {
        return FileManager.default.enumerator(at: url.appendingPathComponent(".git/objects/"), includingPropertiesForKeys: nil)!
            .filter({ !($0 as! URL).hasDirectoryPath }).map({ ($0 as! URL)
                .resolvingSymlinksInPath().path.dropFirst(url.path.count + 13).replacingOccurrences(of: "/", with: "") })
    }
    
    private func add(_ id: String, data: Data, url: URL) throws {
        let folder = url.appendingPathComponent(".git/objects/\(id.prefix(2))")
        let location = folder.appendingPathComponent(String(id.dropFirst(2)))
        if !FileManager.default.fileExists(atPath: location.path) {
            if !FileManager.default.fileExists(atPath: folder.path) {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            }
            try Hub.press.compress(data).write(to: location, options: .atomic)
        }
    }
    
}
