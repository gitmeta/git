import Foundation

public class Repository {
    public let url: URL
    private let hasher = Hash()
    private let press = Press()
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    init(_ url: URL) {
        self.url = url
    }
    
    public func status(_ result: @escaping(([URL: Status]) -> Void)) {
        queue.async { [weak self] in
            guard let status = self?.status else { return }
            DispatchQueue.main.async {
                result(status)
            }
        }
    }
    
    public func add(_ file: URL, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        queue.async { [weak self] in
            self?.add(file)
            DispatchQueue.main.async { done?() }
        }
    }
    
    func tree(_ id: String) throws -> Tree {
        return try Tree(press.decompress(
            try Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))))
    }
    
    private var status: [URL: Status] {
        var status = [URL: Status]()
        let contents = self.contents
        let index = Index(url)
//        status.added = contents.filter({ file in index?.entries.contains(where: { $0.url == file }) == true })
//        status.modified = contents.filter({ file in index?.entries.first(where: { $0.name == file }) != nil })
        contents.filter({ file in index?.entries.contains(where: { $0.url == file }) != true }).forEach { status[$0] = .untracked }
        return status
    }
    
    private var contents: [URL] {
        var result = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        result = result.compactMap({ $0.hasDirectoryPath ? nil : $0.resolvingSymlinksInPath() })
        result.removeAll(where: { $0.path.contains(".git") })
        return result
    }
    
    private func add(_ file: URL) {
        let index = Index(url) ?? Index()
        let hash = hasher.file(file)
        let folder = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        let location = folder.appendingPathComponent(String(hash.1.dropFirst(2)))
        if !FileManager.default.fileExists(atPath: location.path) {
            try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let compressed = press.compress(hash.0)
            try! compressed.write(to: location, options: .atomic)
            index.entry(hash.1, url: file)
            index.save(url)
        }
    }
}
