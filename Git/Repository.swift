import Foundation

public class Repository {
    public var user = Commit.User()
    public let url: URL
    private let hasher = Hash()
    private let press = Press()
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    init(_ url: URL) {
        self.url = url
    }
    
    public func status(_ result: @escaping(([URL: Status]) -> Void)) {
        queue.async { [weak self] in
            guard let contents = self?.contents, let location = self?.url else { return }
            let index = Index(location)
            let status = contents.reduce(into: [URL: Status]()) { result, url in
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
            DispatchQueue.main.async { result(status) }
        }
    }
    
    public func commit(_ files: [URL], message: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        queue.async { [weak self] in
            do {
                try self?.commit(files, message: message)
                done?()
            } catch let exception {
                DispatchQueue.main.async { error?(exception) }
            }
        }
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
    
    private func commit(_ files: [URL], message: String) throws {
        guard !files.isEmpty else { throw Failure.Commit.empty }
        guard !user.name.isEmpty && !user.email.isEmpty else { throw Failure.Commit.credentials }
        guard !message.isEmpty else { throw Failure.Commit.message }
        try files.forEach { try add($0) }
    }
    
    private var contents: [URL] {
        var result = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        result = result.compactMap({ $0.hasDirectoryPath ? nil : $0.resolvingSymlinksInPath() })
        result.removeAll(where: { $0.path.contains(".git") })
        return result
    }
}
