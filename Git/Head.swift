import Foundation

final class Head {
    func branch(_ url: URL) -> String? {
        return try? self.reference(url).replacingOccurrences(of: "refs/heads/", with: "")
    }
    
    func tree(_ url: URL) throws -> Tree {
        return try Tree((commit(url)).tree, url: url)
    }
    
    func commit(_ url: URL) throws -> Commit {
        return try Commit(id(url), url: url)
    }
    
    func id(_ url: URL) throws -> String {
        return String(decoding: try Data(contentsOf: self.url(url)), as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    func update(_ url: URL, id: String) throws {
        try verify(url)
        try Data(id.utf8).write(to: self.url(url), options: .atomic)
    }
    
    func verify(_ url: URL) throws {
        if !FileManager.default.fileExists(atPath: try self.url(url).deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(at: self.url(url).deletingLastPathComponent(), withIntermediateDirectories: true)
        }
    }
    
    func url(_ url: URL) throws -> URL {
        return try url.appendingPathComponent(".git/" + (reference(url)))
    }
    
    func reference(_ url: URL) throws -> String {
        return try String(String(decoding: Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    func origin(_ url: URL, id: String) throws {
        let remotes = url.appendingPathComponent(".git/refs/remotes/origin/")
        if !FileManager.default.fileExists(atPath: remotes.path) {
            try FileManager.default.createDirectory(at: remotes, withIntermediateDirectories: true)
        }
        try Data(id.utf8).write(to: remotes.appendingPathComponent("master"), options: .atomic)
    }
    
    func origin(_ url: URL) -> String? {
        if let data = try? Data(contentsOf: url.appendingPathComponent(".git/refs/remotes/origin/master")) {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
    
    func remote(_ url: URL) -> String? { return (try? Config(url))?.remote.first?.1.url }
}
