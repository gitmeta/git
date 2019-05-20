import Foundation

class Head {
    func tree(_ url: URL) throws -> Tree {
        return try Tree((try commit(url)).tree, url: url)
    }
    
    func commit(_ url: URL) throws -> Commit {
        return try Commit(try Hub.content.get(try id(url), url: url))
    }
    
    func id(_ url: URL) throws -> String {
        return String(decoding: try Data(contentsOf: try self.url(url)), as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    func reference(_ url: URL) throws -> String {
        return String(String(decoding: try Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    func verify(_ url: URL) throws {
        if !FileManager.default.fileExists(atPath: try self.url(url).deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(at: try self.url(url).deletingLastPathComponent(), withIntermediateDirectories: true)
        }
    }
    
    func url(_ url: URL) throws -> URL {
        return url.appendingPathComponent(".git/" + (try reference(url)))
    }
}
