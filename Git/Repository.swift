import Foundation

public class Repository {
    public let url: URL
    private let hasher = Hash()
    private let press = Press()
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    init(_ url: URL) {
        self.url = url
    }
    
    public func status(_ result: @escaping((Status) -> Void)) {
        queue.async { [weak self] in
            guard let status = self?.status else { return }
            DispatchQueue.main.async {
                result(status)
            }
        }
    }
    
    public func add(_ file: String, result: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        queue.async { [weak self] in
            self?.add(file)
            DispatchQueue.main.async { done?() }
        }
    }
    
    func tree(_ id: String) throws -> Tree {
        return try Tree(press.decompress(
            try Data(contentsOf: url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.suffix(id.count - 2))"))))
    }
    
    private var status: Status {
        var status = Status()
        var contents = self.contents
        let index = Index(url)
//        status.added = contents.filter({ file in index?.entries.first(where: { $0.name == file }) != nil })
//        status.modified = contents.filter({ file in index?.entries.first(where: { $0.name == file }) != nil })
        status.untracked = contents.filter({ file in index?.entries.first(where: { $0.name == file }) == nil })
        return status
    }
    
    private var contents: [String] {
        var result = try! FileManager.default.contentsOfDirectory(atPath: url.path)
        result.removeAll(where: { $0 == ".git" })
        return result
    }
    
    private func add(_ file: String) {
        let index = Index(url) ?? Index()
        let original = url.appendingPathComponent(file)
        let id = try! hasher.file(original)
        let folder = url.appendingPathComponent(".git/objects/\(id.prefix(2))")
        let location = folder.appendingPathComponent(String(id.suffix(id.count - 2)))
        if !FileManager.default.fileExists(atPath: location.path) {
            try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let compressed = press.compress(original)
            try! compressed.write(to: location, options: .atomic)
            index.entry(id, name: file, size: compressed.count)
            index.save(url)
        }
    }
}
