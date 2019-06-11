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
        try rest.download(remote, error: error) {
            guard let reference = $0.branch.first else { throw Failure.Fetch.empty }
            guard let name = remote.components(separatedBy: "/").last?.replacingOccurrences(of: ".git", with: ""), !name.isEmpty
                else { throw Failure.Clone.name }
            let directory = local.appendingPathComponent(name)
            guard !FileManager.default.fileExists(atPath: directory.path) else { throw Failure.Clone.directory }
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
            try self.rest.pull(remote, want: reference, error: error) {
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
        try rest.download(Hub.head.remote(repository.url), error: error) {
            guard let reference = $0.branch.first else { throw Failure.Fetch.empty }
            if reference == Hub.head.origin(repository.url) {
                done()
            } else {
                try self.rest.pull(Hub.head.remote(repository.url), want: reference, have:
                Hub.content.objects(repository.url).reduce(into: "") { $0 += "0032have \($1)\n" }, error: error) {
                    try $0.unpack(repository.url)
                    if try repository.merger.needs(reference) {
                        try repository.check.merge(reference)
                        try repository.stage.merge(reference)
                    } else {
                        try repository.check.check(reference)
                        try Hub.head.update(repository.url, id: reference)
                    }
                    try Hub.head.origin(repository.url, id: reference)
                    done()
                }
            }
        }
    }
    
    func push(_ repository: Repository, error: @escaping((Error) -> Void), done: @escaping(() -> Void)) throws {
        try rest.upload(Hub.head.remote(repository.url), error: error) {
            guard let reference = $0.branch.first, let current = try? Hub.head.id(repository.url), reference != current
            else { return done() }
            try self.rest.push(Hub.head.remote(repository.url), old: reference, new: current, pack: Pack.Maker(repository.url, from: current, to: reference).data, error: error) {
                try Hub.head.origin(repository.url, id: reference)
                done()
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
