import Foundation

final class History {
    private(set) var result = [Commit]()
    private var map = [String: Commit]()
    private let url: URL
    
    init(_ url: URL) throws {
        self.url = url
        try commits(try Hub.head.id(url))
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
        let item = try Commit(try Hub.content.get(id, url: url))
        map[id] = item
        try item.parent.forEach {
            try commits($0)
        }
    }
}
