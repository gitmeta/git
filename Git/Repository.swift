import Foundation

public final class Repository {
    public var status: (([(URL, Status)]) -> Void)?
    public let url: URL
    let state = State()
    let stage = Stage()
    let extract = Extract()
    let packer = Packer()
    
    init(_ url: URL) {
        self.url = url
        state.repository = self
        stage.repository = self
        extract.repository = self
        packer.repository = self
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
    
    public func reset(_ error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) { extract.reset(error ?? { _ in }, done: done ?? { }) }
    public func unpack(_ error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) { packer.unpack(error ?? { _ in }, done: done ?? { }) }
    public func packed(_ result: @escaping((Bool) -> Void)) { packer.packed(result) }
    public func refresh() { state.refresh() }
    public func branch(_ result: @escaping((String) -> Void)) { Hub.head.branch(url, result: result) }
    
    private func commits(_ id: String, map: inout[String: Commit]) throws {
        guard map[id] == nil else { return }
        let item = try Commit(try Hub.content.get(id, url: url))
        map[id] = item
        try item.parent.forEach {
            try commits($0, map: &map)
        }
    }
}
