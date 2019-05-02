import Foundation

public class Repository {
    public var status: (([(URL, Status)]) -> Void)?
    public let url: URL
    var updated = Date.distantPast
    let timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
    private let hasher = Hash()
    private let press = Press()
    private let dispatch = Dispatch()
    
    init(_ url: URL) {
        self.url = url
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            self?.dispatch.background({ [weak self] in
                return self?.needsStatus == true ? self?.statusList : nil
            }) { [weak self] in
                if let changes = $0 {
                    self?.status?(changes)
                }
                self?.timer.schedule(deadline: .now() + 1)
            }
        }
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        dispatch.background({ [weak self] in
            guard let url = self?.url else { return }
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
            commit.parent = self?.headId
            commit.save(url)
            index.save(url)
        }, error: error, success: done ?? { })
    }
    
    public func refresh() {
        updated = Date.distantPast
        timer.schedule(deadline: .now() + 1)
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
        return try? Tree(head.tree, url: url)
    }
    
    var needsStatus: Bool {
        if let modified = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date,
            modified > updated { return true }
        return modified([url])
    }
    
    var statusList: [(URL, Status)] {
        updated = Date()
        let contents = self.contents
        let index = Index(url)
        let pack = Pack.load(url)
        var tree = self.tree?.list(url) ?? []
        return contents.reduce(into: [(URL, Status)]()) { result, url in
            if let entries = index?.entries.filter({ $0.url == url }), !entries.isEmpty {
                let hash = hasher.file(url).1
                if entries.contains(where: { $0.id == hash }) {
                    if !tree.contains(where: { $0.id == hash }) {
                        if !pack.contains(where: { packed in packed.entries.contains(where: { $0.0 == hash } ) }) {
                            result.append((url, .added))
                        }
                    }
                } else {
                    result.append((url, .modified))
                }
                tree.removeAll { $0.url == url }
            } else {
                result.append((url, .untracked))
            }
        } + tree.map({ ($0.url, .deleted) })
    }
    
    func add(_ file: URL, index: Index) throws {
        guard file.path.contains(url.path) else { throw Failure.Add.outside }
        guard FileManager.default.fileExists(atPath: file.path) else { throw Failure.Add.not }
        let hash = hasher.file(file)
        guard !index.entries.contains(where: { $0.url.path == file.path && $0.id == hash.1 }) else { throw Failure.Add.double }
        let folder = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        let location = folder.appendingPathComponent(String(hash.1.dropFirst(2)))
        if !FileManager.default.fileExists(atPath: location.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let compressed = press.compress(hash.0)
            try compressed.write(to: location, options: .atomic)
        }
        index.entry(hash.1, url: file)
    }
    
    private var contents: [URL] {
        let ignore = Ignore(url)
        return FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)?
            .map({ ($0 as! URL).resolvingSymlinksInPath() })
            .filter({ !ignore.url($0) })
            .sorted(by: { $0.path.compare($1.path, options: .caseInsensitive) != .orderedDescending }) ?? []
    }
    
    private func modified(_ urls: [URL]) -> Bool {
        var urls = urls
        guard
            !urls.isEmpty,
            let contents = try? FileManager.default.contentsOfDirectory(at: urls.first!, includingPropertiesForKeys:
                [.contentModificationDateKey])
        else { return false }
        for item in contents {
            if item.hasDirectoryPath {
                if let modified = try? item.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                    modified > updated {
                    return true
                }
            }
            urls.append(item)
        }
        return modified(Array(urls.dropFirst()))
    }
}
