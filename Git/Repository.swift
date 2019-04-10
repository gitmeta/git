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
        if let index = Index.load(url) {
            
        }
        status.untracked.append(contentsOf: contents)
        return status
    }
    
    private var contents: [String] {
        return try! FileManager.default.contentsOfDirectory(atPath: url.path)
    }
    
    private func add(_ file: String) {
        let index = Index.load(url) ?? Index.new(url)
        let original = url.appendingPathComponent(file)
        let hash = try! hasher.file(original)
        let directory = String(hash[hash.startIndex ..< hash.index(hash.startIndex, offsetBy: 2)])
        let name = String(hash[hash.index(hash.startIndex, offsetBy: 2)...])
        let folder = url.appendingPathComponent(".git/objects/\(directory)/\(name)")
        let compressed = folder.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: compressed.path) {
            try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try! press.compress(original).write(to: compressed, options: .atomic)
            print(compressed)
        }
    }
}
