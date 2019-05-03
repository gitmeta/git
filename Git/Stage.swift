import Foundation

class Stage {
    weak var repository: Repository?
    
    func commit(_ files: [URL], message: String, error: ((Error) -> Void)?, done: (() -> Void)?) {
        Git.dispatch.background({ [weak self] in
            guard let url = self?.repository?.url else { return }
            guard !files.isEmpty else { throw Failure.Commit.empty }
            guard !Git.session.name.isEmpty else { throw Failure.Commit.credentials }
            guard !Git.session.email.isEmpty else { throw Failure.Commit.credentials }
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
            commit.author.name = Git.session.name
            commit.author.email = Git.session.email
            commit.committer.name = Git.session.name
            commit.committer.email = Git.session.email
            commit.tree = treeId
            commit.message = message
            commit.parent = self?.repository?.headId
            commit.save(url)
            index.save(url)
        }, error: error, success: done ?? { })
    }
    
    func add(_ file: URL, index: Index) throws {
        guard let url = repository?.url else { return }
        guard file.path.contains(url.path) else { throw Failure.Add.outside }
        guard FileManager.default.fileExists(atPath: file.path) else { throw Failure.Add.not }
        let hash = Git.hash.file(file)
        guard !index.entries.contains(where: { $0.url.path == file.path && $0.id == hash.1 }) else { throw Failure.Add.double }
        let folder = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        let location = folder.appendingPathComponent(String(hash.1.dropFirst(2)))
        if !FileManager.default.fileExists(atPath: location.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let compressed = Git.press.compress(hash.0)
            try compressed.write(to: location, options: .atomic)
        }
        index.entry(hash.1, url: file)
    }
}
