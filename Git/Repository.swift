import Foundation

public class Repository {
    public let url: URL
    private let hasher = Hash()
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
        var index = Index.load(url) ?? Index.new(url)
        let hash = try! hasher.file(url.appendingPathComponent(file))
        let directory = String(hash[hash.startIndex ..< hash.index(hash.startIndex, offsetBy: 2)])
        let name = String(hash[hash.index(hash.startIndex, offsetBy: 2)...])
        if !FileManager.default.fileExists(atPath: url.appendingPathComponent("\(directory)/\(name)").path) {
            try! FileManager.default.createDirectory(atPath: String(hash[hash.startIndex ..< hash.index(hash.startIndex, offsetBy:
                2)]), withIntermediateDirectories: true)
            // save file compressed
        }
    }
}
