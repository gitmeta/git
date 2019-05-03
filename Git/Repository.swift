import Foundation

public class Repository {
    public var status: (([(URL, Status)]) -> Void)?
    public let url: URL
    let state = State()
    let stage = Stage()
    
    init(_ url: URL) {
        self.url = url
        state.repository = self
        stage.repository = self
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        stage.commit(files, message: message, error: error, done: done)
    }
    
    public func refresh() { state.refresh() }
    
    var HEAD: String {
        return String(String(decoding: try! Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    var headId: String? {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/" + HEAD)) else { return nil }
        return String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    var head: Commit? {
        guard
            let id = self.headId,
            let raw = try? Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))
        else { return nil }
        return try? Commit(Git.press.decompress(raw))
    }
    
    var tree: Tree? {
        guard let head = self.head else { return nil }
        return try? Tree(head.tree, url: url)
    }
}
