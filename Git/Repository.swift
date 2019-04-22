import Foundation

public class Repository {
    public var user = Commit.User()
    public let url: URL
    private let hasher = Hash()
    private let press = Press()
    private let dispatch = Dispatch()
    
    init(_ url: URL) {
        self.url = url
    }
    
    public func status(_ result: @escaping(([(URL, Status)]) -> Void)) {
        dispatch.background({ [weak self] in
            guard let location = self?.url, let contents = self?.contents, let hasher = self?.hasher else { return [] }
            let index = Index(location)
            var tree = self?.tree?.items ?? []
            return contents.reduce(into: [(URL, Status)]()) { result, url in
                if let entries = index?.entries.filter({ $0.url == url }), !entries.isEmpty {
                    let hash = hasher.file(url).1
                    if entries.contains(where: { $0.id == hash }) {
                        if !tree.contains(where: { $0.id == hash }) {
                            result.append((url, .added))
                        }
                    } else {
                        result.append((url, .modified))
                    }
                    tree.removeAll { $0.url == url }
                } else {
                    result.append((url, .untracked))
                }
            } + tree.map({ ($0.url, .deleted) })
        }, success: result)
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        dispatch.background({ [weak self] in
            guard let url = self?.url, let user = self?.user else { return }
            guard !files.isEmpty else { throw Failure.Commit.empty }
            guard !user.name.isEmpty else { throw Failure.Commit.credentials }
            guard !user.email.isEmpty else { throw Failure.Commit.credentials }
            guard !message.isEmpty else { throw Failure.Commit.message }
            user.date = Date()
            let index = Index(url) ?? Index()
            let tree = Tree(url)
            let treeId = tree.save(url)
            try files.forEach { try self?.add($0, index: index) }
            index.directory(treeId, url: url, tree: tree)
            let commit = Commit()
            commit.author = user
            commit.committer = user
            commit.tree = treeId
            commit.message = message
            commit.parent = self?.headId
            commit.save(url)
            index.save(url)
        }, error: error, success: done ?? { })
    }
    
    var HEAD: String {
        return String(String(decoding: try! Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5)).replacingOccurrences(of: "\n", with: "")
    }
    
    var headId: String? {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/" + HEAD)) else { return nil }
        return String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\n", with: "")
    }
    
    var head: Commit? {
        guard
            let id = self.headId,
            let raw = try? Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))
        else { return nil }
        return try? Commit(press.decompress(raw))
    }
    
    var tree: Tree? {
        guard let head = self.head else { return nil }
        return try? tree(head.tree)
    }
    
    func add(_ file: URL, index: Index) throws {
        guard file.path.contains(url.path) else { throw Failure.Add.outside }
        guard FileManager.default.fileExists(atPath: file.path) else { throw Failure.Add.not }
        let hash = hasher.file(file)
        let folder = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        let location = folder.appendingPathComponent(String(hash.1.dropFirst(2)))
        guard !FileManager.default.fileExists(atPath: location.path) else { throw Failure.Add.double }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let compressed = press.compress(hash.0)
        try compressed.write(to: location, options: .atomic)
        index.entry(hash.1, url: file)
    }
    
    func tree(_ id: String) throws -> Tree {
        return try Tree(press.decompress(
            try Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))), url: url)
    }
    
    private var contents: [URL] {
        let ignore = Ignore(url)
        return FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)?
            .map({ ($0 as! URL).resolvingSymlinksInPath() })
            .filter({ !ignore.url($0) })
            .sorted(by: { $0.path.compare($1.path, options: .caseInsensitive) != .orderedDescending }) ?? []
    }
}
