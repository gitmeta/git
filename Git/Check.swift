import Foundation

final class Check {
    weak var repository: Repository?
    
    func reset() throws {
        guard let url = repository?.url, let tree = try? Hub.head.tree(url) else { return }
        try check(tree)
    }
    
    func check(_ id: String) throws {
        guard let url = repository?.url else { return }
        try check(Tree(Commit(id, url: url).tree, url: url))
        try Hub.head.update(url, id: id)
    }
    
    func merge(_ id: String) throws {
        guard let url = repository?.url else { return }
        var tree = try Hub.head.tree(url).items
        try Tree(Commit(id, url: url).tree, url: url).items.forEach { item in
            if !tree.contains(where: { $0.id == item.id }) {
                tree.append(item)
            }
        }
        let index = Index()
        try extract(tree, index: index)
        index.save(url)
    }
    
    private func check(_ tree: Tree) throws {
        guard let url = repository?.url else { return }
        try remove(tree)
        let index = Index()
        try extract(tree.items, index: index)
        index.save(url)
    }
    
    private func remove(_ tree: Tree) throws {
        guard let url = repository?.url, let list = repository?.state.list(tree) else { return }
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
    
    private func extract(_ tree: [Tree.Item], index: Index) throws {
        guard let url = repository?.url else { return }
        try tree.forEach {
            switch $0.category {
            case .tree:
                if !FileManager.default.fileExists(atPath: $0.url.path) {
                    try FileManager.default.createDirectory(at: $0.url, withIntermediateDirectories: true)
                }
                try extract(Tree($0.id, url: url, trail: $0.url).items, index: index)
            default:
                try Hub.content.file($0.id, url: url).write(to: $0.url, options: .atomic)
                index.entry($0.id, url: $0.url)
            }
        }
    }
}
