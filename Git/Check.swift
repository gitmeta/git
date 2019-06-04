import Foundation

final class Check {
    weak var repository: Repository?
    
    func reset() throws {
        guard let url = repository?.url, let tree = try? Hub.head.tree(url) else { return }
        try check(tree)
    }
    
    func check(_ id: String) throws {
        guard let url = repository?.url else { return }
        try check(Tree(Commit(Hub.content.get(id, url: url)).tree, url: url))
        try Hub.head.update(url, id: id)
    }
    
    private func check(_ tree: Tree) throws {
        guard let url = repository?.url else { return }
        try remove()
        let index = Index()
        try extract(tree, index: index)
        index.save(url)
    }
    
    private func remove() throws {
        guard let list = repository?.state.list else { return }
        try remove(list)
    }
    
    private func remove(_ list: [(URL, Status)]) throws {
        guard let url = repository?.url else { return }
        try list.filter({ $0.1 != .deleted }).forEach {
            let path = $0.0.deletingLastPathComponent().path.dropFirst(url.path.count)
            if !path.isEmpty {
                let dir = url.appendingPathComponent(String(path))
                if FileManager.default.fileExists(atPath: dir.path) {
                    try FileManager.default.removeItem(at: dir)
                }
            } else {
                if FileManager.default.fileExists(atPath: $0.0.path) {
                    try FileManager.default.removeItem(at: $0.0)
                }
            }
        }
    }
    
    private func extract(_ tree: Tree, index: Index) throws {
        guard let url = repository?.url else { return }
        try tree.items.forEach {
            switch $0.category {
            case .tree:
                if !FileManager.default.fileExists(atPath: $0.url.path) {
                    try FileManager.default.createDirectory(at: $0.url, withIntermediateDirectories: true)
                }
                try extract(try Tree($0.id, url: url, trail: $0.url), index: index)
            default:
                let data = try Hub.content.get($0.id, url: url)
                let parse = Parse(data)
                _ = try parse.ascii("\u{0000}")
                try parse.data.subdata(in: parse.index ..< parse.data.count).write(to: $0.url, options: .atomic)
                index.entry($0.id, url: $0.url)
            }
        }
    }
}
