import Foundation

class Extract {
    weak var repository: Repository?
    
    func reset(_ error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let tree = self?.repository?.tree, let list = self?.repository?.state.list else { return }
            try self?.remove(list)
            try self?.extract(tree)
        }, error: error, success: done)
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
    
    private func extract(_ tree: Tree) throws {
        guard let url = repository?.url else { return }
        try tree.items.forEach {
            switch $0.category {
            case .sub:
                if !FileManager.default.fileExists(atPath: $0.url.path) {
                    try FileManager.default.createDirectory(at: $0.url, withIntermediateDirectories: true)
                }
                try extract(try Tree($0.id, url: url, trail: $0.url))
            default:
                guard let data = repository?.item($0.id) else { return }
                let parse = Parse(data)
                _ = try parse.ascii("\u{0000}")
                try parse.data.subdata(in: parse.index ..< parse.data.count).write(to: $0.url, options: .atomic)
            }
        }
    }
}
