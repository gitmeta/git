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
            if let url = self?.url, let id = try? Hub.head.id(url) {
                try? self?.commits(id, map: &result)
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
    public var branch: String { return (try? Hub.head.reference(url).replacingOccurrences(of: "refs/heads/", with: "")) ?? "" }
    
    private func commits(_ id: String, map: inout[String: Commit]) throws {
        guard map[id] == nil else { return }
        let item = try Commit(try Hub.content.get(id, url: url))
        map[id] = item
        try item.parent.forEach {
            try commits($0, map: &map)
        }
    }
}
