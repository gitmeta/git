import Foundation

final class Merger {
    weak var repository: Repository?
    
    func merge(_ id: String) throws {
        guard let url = repository?.url, let local = try? History(url), let remote = try? History(id, url: url) else { return }
        var found = false
        var index = 0
        let keys = Array(local.map.keys)
        while !found && index < keys.count {
            found = remote.map[keys[index]] != nil
            index += 1
        }
        if !found {
            throw Failure.Merge.common
        }
    }
}
