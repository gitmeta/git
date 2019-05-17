import Foundation

public class Repository {
    public var status: (([(URL, Status)]) -> Void)?
    public let url: URL
    let state = State()
    let stage = Stage()
    let extract = Extract()
    
    init(_ url: URL) {
        self.url = url
        state.repository = self
        stage.repository = self
        extract.repository = self
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        stage.commit(files, message: message, error: error ?? { _ in }, done: done ?? { })
    }
    
    public func log(_ result: @escaping(([Commit]) -> Void)) {
        Hub.dispatch.background({ [weak self] in
            var result = [String: Commit]()
            if let id = self?.headId {
                self?.commits(id, map: &result)
            }
            return result.values.sorted(by: {
                if $0.author.date > $1.author.date {
                    return true
                } else if $0.author.date == $1.author.date {
                    return $0.parent.count > $1.parent.count
                }
                return false
            })
        }, success: result)
    }
    
    public func reset(_ error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        extract.reset(error ?? { _ in }, done: done ?? { })
    }
    
    public func refresh() { state.refresh() }
    
    public var branch: String {
        return HEAD.replacingOccurrences(of: "refs/heads/", with: "")
    }
    
    var HEAD: String {
        return String(String(decoding: try! Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    var headId: String? {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/" + HEAD)) else { return nil }
        return String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    var head: Commit? {
        guard let id = self.headId else { return nil }
        return commit(id)
    }
    
    var tree: Tree? {
        guard let head = self.head else { return nil }
        return try? Tree(head.tree, url: url)
    }
    
    private func commits(_ id: String, map: inout[String: Commit]) {
        guard map[id] == nil, let item = commit(id) else { return }
        map[id] = item
        item.parent.forEach {
            commits($0, map: &map)
        }
    }
    
    private func commit(_ id: String) -> Commit? {
        guard let raw = try? Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))
        else { return nil }
        return try? Commit(Hub.press.decompress(raw))
    }
}
