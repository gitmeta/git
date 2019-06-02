import Foundation

final class Head {
    func branch(_ url: URL) -> String? {
        return try? self.reference(url).replacingOccurrences(of: "refs/heads/", with: "")
    }
    
    func tree(_ url: URL) throws -> Tree {
        return try Tree((try commit(url)).tree, url: url)
    }
    
    func commit(_ url: URL) throws -> Commit {
        return try Commit(try Hub.content.get(try id(url), url: url))
    }
    
    func id(_ url: URL) throws -> String {
        return String(decoding: try Data(contentsOf: try self.url(url)), as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    func update(_ url: URL, id: String) throws {
        try verify(url)
        try Data(id.utf8).write(to: try self.url(url), options: .atomic)
    }
    
    func verify(_ url: URL) throws {
        if !FileManager.default.fileExists(atPath: try self.url(url).deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(at: try self.url(url).deletingLastPathComponent(), withIntermediateDirectories: true)
        }
    }
    
    func url(_ url: URL) throws -> URL {
        return url.appendingPathComponent(".git/" + (try reference(url)))
    }
    
    func reference(_ url: URL) throws -> String {
        return String(String(decoding: try Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    func remote(_ url: URL, id: String) throws {
        let remotes = url.appendingPathComponent(".git/refs/remotes/origin/")
        if !FileManager.default.fileExists(atPath: remotes.path) {
            try FileManager.default.createDirectory(at: remotes, withIntermediateDirectories: true)
        }
        try Data(id.utf8).write(to: remotes.appendingPathComponent("master"), options: .atomic)
    }
    
    func remote(_ url: URL) -> String? {
        if let data = try? Data(contentsOf: url.appendingPathComponent(".git/refs/remotes/origin/master")) {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
}
