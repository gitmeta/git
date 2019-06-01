import Foundation

final class History {
    weak var repository: Repository?
    
    func log() throws -> [Commit]? {
        guard let url = repository?.url else { return nil }
        var result = [String: Commit]()
        try commits(try Hub.head.id(url), map: &result, url: url)
        return result.values.sorted(by: {
            if $0.author.date > $1.author.date {
                return true
            } else if $0.author.date == $1.author.date {
                return $0.parent.count > $1.parent.count
            }
            return false
        })
    }
    
    private func commits(_ id: String, map: inout[String: Commit], url: URL) throws {
        guard map[id] == nil else { return }
        let item = try Commit(try Hub.content.get(id, url: url))
        map[id] = item
        try item.parent.forEach {
            try commits($0, map: &map, url: url)
        }
    }
}
