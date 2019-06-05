import Foundation

final class Merger {
    weak var repository: Repository?
    
    func needs(_ id: String) throws -> Bool {
        guard let url = repository?.url, let local = try? History(url), let remote = try? History(id, url: url) else { return false }
        var same = false
        var index = 0
        let keys = Array(local.map.keys)
        while !same && index < keys.count {
            same = remote.map[keys[index]] != nil
            index += 1
        }
        if !same {
            throw Failure.Merge.common
        }
        return remote.map[try Hub.head.id(url)] == nil && local.map[id] == nil
    }
}
