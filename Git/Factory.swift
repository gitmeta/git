import Foundation

final class Factory {
    var rest = Rest()
    
    func open(_ url: URL) throws -> Repository {
        if repository(url) {
            return Repository(url)
        }
        throw Failure.Repository.invalid
    }
    
    func clone(_ remote: String, local: URL, error: @escaping((Error) -> Void), result: @escaping((URL) -> Void)) throws {
        if repository(local) { throw Failure.Clone.already }
        guard let name = remote.components(separatedBy: "/").last?.replacingOccurrences(of: ".git", with: ""), !name.isEmpty
        else { throw Failure.Clone.name }
        let directory = local.appendingPathComponent(name)
        guard !FileManager.default.fileExists(atPath: directory.path) else { throw Failure.Clone.directory }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        try rest.fetch(remote, error: error) {
            guard let reference = $0.refs.first else { throw Failure.Fetch.empty }
            try self.rest.pack(remote, want: reference, error: error) {
                let repository = try self.create(directory)
                try $0.unpack(directory)
                try repository.check.check(reference)
                try Hub.head.update(directory, id: reference)
                try Hub.head.origin(directory, id: reference)
                try Config(remote).save(directory)
                DispatchQueue.main.async { result(directory) }
            }
        }
    }
    
    func pull(_ repository: Repository, error: @escaping((Error) -> Void), done: @escaping(() -> Void)) throws {
        guard let raw = Hub.head.remote(repository.url) else { throw Failure.Pull.remote }
        let remote = raw.hasPrefix("https://") ? String(raw.dropFirst(8)) : raw
        try rest.fetch(remote, error: error) {
            guard let reference = $0.refs.first else { throw Failure.Fetch.empty }
            if reference == Hub.head.origin(repository.url) {
                done()
            } else {
                try self.rest.pack(remote, want: reference, have:
                Hub.content.objects(repository.url).reduce(into: "") { $0 += "0032have \($1) " }, error: error) {
                    try $0.unpack(repository.url)
                    try repository.merger.merge(reference)
                    try repository.check.check(reference)
                    try Hub.head.update(repository.url, id: reference)
                    try Hub.head.origin(repository.url, id: reference)
                    done()
                }
            }
        }
    }
    
    func create(_ url: URL) throws -> Repository {
        guard !repository(url) else { throw Failure.Repository.duplicating }
        let root = url.appendingPathComponent(".git")
        let objects = root.appendingPathComponent("objects")
        let refs = root.appendingPathComponent("refs")
        let head = root.appendingPathComponent("HEAD")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: refs, withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: objects, withIntermediateDirectories: false)
        try Data("ref: refs/heads/master".utf8).write(to: head, options: .atomic)
        return try open(url)
    }
    
    func delete(_ repository: Repository) throws {
        try FileManager.default.removeItem(at: repository.url.appendingPathComponent(".git"))
    }
    
    func repository(_ url: URL) -> Bool {
        var d: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/refs").path, isDirectory: &d),
            d.boolValue,
            FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects").path, isDirectory: &d),
            d.boolValue,
            let reference = try? Hub.head.reference(url),
            reference.contains("refs") else { return false }
        return true
    }
}
