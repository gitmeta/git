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
    
    public func status(_ result: @escaping(([URL: Status]) -> Void)) {
        dispatch.background({ [weak self] in
            guard let contents = self?.contents, let location = self?.url else { return [:] }
            let index = Index(location)
            return contents.reduce(into: [URL: Status]()) { result, url in
                if let entries = index?.entries.filter({ $0.url == url }) {
                    if let hash = self?.hasher.file(url).1,
                        let tracked = entries.first(where: { $0.id == hash }) {
                        result[url] = .added
                    } else {
                        result[url] = .modified
                    }
                } else {
                    result[url] = .untracked
                }
            }
        }, success: result)
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        dispatch.background({ [weak self] in
            guard let url = self?.url, let user = self?.user else { return }
            guard !files.isEmpty else { throw Failure.Commit.empty }
            guard !user.name.isEmpty else { throw Failure.Commit.credentials }
            guard !user.email.isEmpty else { throw Failure.Commit.credentials }
            guard !message.isEmpty else { throw Failure.Commit.message }
            try files.forEach { try self?.add($0) }
            user.date = Date()
            let commit = Commit()
            commit.author = user
            commit.committer = user
            commit.tree = Tree.save(url)
            commit.message = message
            commit.parent = self?.headId
            commit.save(url)
        }, error: error, success: done ?? { })
    }
    
    var HEAD: String {
        return String(String(decoding: try! Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as:
            UTF8.self).dropFirst(5))
    }
    
    var headId: String? {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".git/" + HEAD)) else { return nil }
        return String(decoding: data, as: UTF8.self)
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
    
    func add(_ file: URL) throws {
        let index = Index(url) ?? Index()
        let hash = hasher.file(file)
        let folder = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        let location = folder.appendingPathComponent(String(hash.1.dropFirst(2)))
        guard !FileManager.default.fileExists(atPath: location.path) else { throw Failure.Add.double }
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let compressed = press.compress(hash.0)
        try compressed.write(to: location, options: .atomic)
        index.entry(hash.1, url: file)
        index.save(url)
    }
    
    func tree(_ id: String) throws -> Tree {
        return try Tree(press.decompress(
            try Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))))
    }
    
    private var contents: [URL] {
        var result = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        result = result.compactMap({ $0.hasDirectoryPath ? nil : $0.resolvingSymlinksInPath() })
        result.removeAll(where: { $0.path.contains(".git") })
        return result
    }
}
