import Foundation

final class History {
    private(set) var result = [Commit]()
    private(set) var map = [String: Commit]()
    private let url: URL
    
    convenience init(_ url: URL) throws {
        try self.init(Hub.head.id(url), url: url)
    }
    
    init(_ id: String, url: URL) throws {
        self.url = url
        try commits(id)
        result = map.values.sorted {
            if $0.author.date > $1.author.date {
                return true
            } else if $0.author.date == $1.author.date {
                return $0.parent.count > $1.parent.count
            }
            return false
        }
    }
    
    private func commits(_ id: String) throws {
        guard map[id] == nil else { return }
        let item = try Commit(id, url: url)
        map[id] = item
        try item.parent.forEach {
            try commits($0)
        }
    }
}
