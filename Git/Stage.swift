import Foundation

final class Stage {
    weak var repository: Repository?
    
    func commit(_ files: [URL], message: String) throws {
        guard let url = repository?.url else { return }
        guard !files.isEmpty else { throw Failure.Commit.empty }
        guard !Hub.session.name.isEmpty else { throw Failure.Commit.credentials }
        guard !Hub.session.email.isEmpty else { throw Failure.Commit.credentials }
        guard !message.isEmpty else { throw Failure.Commit.message }
        let index = Index(url) ?? Index()
        let ignore = Ignore(url)
        let tree = Tree(url, ignore: ignore, update: files, entries: index.entries)
        let treeId = try tree.save(url)
        try files.forEach {
            guard !ignore.url($0) else { throw Failure.Commit.ignored }
            try? add($0, index: index)
        }
        let commit = Commit()
        commit.author.name = Hub.session.name
        commit.author.email = Hub.session.email
        commit.committer.name = Hub.session.name
        commit.committer.email = Hub.session.email
        commit.tree = treeId
        commit.message = message
        if let parent = try? Hub.head.id(url) {
            commit.parent.append(parent)
        }
        try Hub.head.update(url, id: Hub.content.add(commit, url: url))
        index.save(url)
    }
    
    func add(_ file: URL, index: Index) throws {
        guard let url = repository?.url else { return }
        guard file.path.contains(url.path) else { throw Failure.Add.outside }
        guard FileManager.default.fileExists(atPath: file.path) else { throw Failure.Add.not }
        let hash = try Hub.content.add(file, url: url)
        index.entry(hash, url: file)
    }
}
