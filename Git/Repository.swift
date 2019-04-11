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
    
    public func add(_ file: String, done: (() -> Void)?) {
        queue.async { [weak self] in
            self?.add(file)
            DispatchQueue.main.async { done?() }
        }
    }
    
    private var status: Status {
        var status = Status()
        var contents = self.contents
        if let index = Index(url) {
            
        }
        status.untracked.append(contentsOf: contents)
        return status
    }
    
    private var contents: [String] {
        return try! FileManager.default.contentsOfDirectory(atPath: url.path)
    }
    
    private func add(_ file: String) {
        let index = Index(url) ?? Index()
        let original = url.appendingPathComponent(file)
        let id = try! hasher.file(original)
        let folder = url.appendingPathComponent(".git/objects/\(String(id[id.startIndex ..< id.index(id.startIndex, offsetBy: 2)]))")
        let location = folder.appendingPathComponent(String(id[id.index(id.startIndex, offsetBy: 2)...]))
        if !FileManager.default.fileExists(atPath: location.path) {
            try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let compressed = press.compress(original)
            try! compressed.write(to: location, options: .atomic)
            index.entry(id, name: file, size: compressed.count)
            index.save(url)
        }
    }
}
