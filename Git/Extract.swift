import Foundation

class Extract {
    weak var repository: Repository?
    
    func reset(_ error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let tree = self?.repository?.tree else { return }
            try self?.extract(tree)
        }, error: error, success: done)
    }
    
    private func extract(_ tree: Tree) throws {
        guard let url = repository?.url else { return }
        try tree.items.forEach {
            switch $0.category {
            case .sub:
                try FileManager.default.createDirectory(at: $0.url, withIntermediateDirectories: true)
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
