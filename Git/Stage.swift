import Foundation

class Stage {
    weak var repository: Repository?
    
    func commit(_ files: [URL], message: String, error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let url = self?.repository?.url else { return }
            guard !files.isEmpty else { throw Failure.Commit.empty }
            guard !Hub.session.name.isEmpty else { throw Failure.Commit.credentials }
            guard !Hub.session.email.isEmpty else { throw Failure.Commit.credentials }
            guard !message.isEmpty else { throw Failure.Commit.message }
            let index = Index(url) ?? Index()
            let ignore = Ignore(url)
            let tree = Tree(url, ignore: ignore, update: files, entries: index.entries)
            let treeId = tree.save(url)
            try files.forEach {
                guard !ignore.url($0) else { throw Failure.Commit.ignored }
                try? self?.add($0, index: index)
            }
            let commit = Commit()
            commit.author.name = Hub.session.name
            commit.author.email = Hub.session.email
            commit.committer.name = Hub.session.name
            commit.committer.email = Hub.session.email
            commit.tree = treeId
            commit.message = message
            if let parent = self?.repository?.headId {
                commit.parent.append(parent)
            }
            commit.save(url)
            index.save(url)
        }, error: error, success: done)
    }
    
    func add(_ file: URL, index: Index) throws {
        guard let url = repository?.url else { return }
        guard file.path.contains(url.path) else { throw Failure.Add.outside }
        guard FileManager.default.fileExists(atPath: file.path) else { throw Failure.Add.not }
        let hash = Hub.hash.file(file)
        guard !index.entries.contains(where: { $0.url.path == file.path && $0.id == hash.1 }) else { throw Failure.Add.double }
        try Hub.add(url, id: hash.1, data: hash.0)
        index.entry(hash.1, url: file)
    }
}
