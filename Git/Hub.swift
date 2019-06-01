import Foundation

public final class Hub {
    public internal(set) static var session = Session()
    static var rest = Rest()
    static let dispatch = Dispatch()
    static let hash = Hash()
    static let press = Press()
    static let content = Content()
    static let head = Head()
    
    public class func repository(_ url: URL, result: @escaping((Bool) -> Void)) {
        dispatch.background({ repository(url) }, success: result)
    }
    
    public class func create(_ url: URL, error: @escaping((Error) -> Void) = { _ in }, result: @escaping((Repository) -> Void) = { _ in }) {
        dispatch.background({
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
        }, error: error, success: result)
    }
    
    public class func open(_ url: URL, error: @escaping((Error) -> Void) = { _ in }, result: @escaping((Repository) -> Void)) {
        dispatch.background({
            return try open(url)
        }, error: error, success: result)
    }
    
    public class func delete(_ repository: Repository, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        dispatch.background({
            try FileManager.default.removeItem(at: repository.url.appendingPathComponent(".git"))
        }, error: error, success: done)
    }
    
    public class func clone(_ remote: String, local: URL, error: @escaping((Error) -> Void) = { _ in }, result: @escaping((URL) -> Void) = { _ in }) {
        dispatch.background({
            if repository(local) {
                throw Failure.Clone.already
            }
            try rest.adv(remote, error: { exception in
                DispatchQueue.main.async { error(exception) }
            }) { adv in
                dispatch.background({
                    if adv.refs.isEmpty {
                        throw Failure.Fetch.empty
                    }
                    try rest.pack(remote, want: adv.refs.first!, error: { exception in
                        DispatchQueue.main.async { error(exception) }
                    }, result: { pack in
                        dispatch.background({
                            guard let name = remote.components(separatedBy: "/").last?.replacingOccurrences(of:".git", with: ""),
                                !name.isEmpty
                            else { throw Failure.Clone.name }
                            let directory = local.appendingPathComponent(name)
                            guard !FileManager.default.fileExists(atPath: directory.path) else { throw Failure.Clone.directory }
                            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
                            
                            create(directory, error: error) { _ in
                                
                            }
//                            return directory
                        }, error: error)
                    })
                }, error: error)
            }
        }, error: error)
    }
    
    private class func repository(_ url: URL) -> Bool {
        var d: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/refs").path, isDirectory: &d),
            d.boolValue,
            FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects").path, isDirectory: &d),
            d.boolValue,
            let reference = try? Hub.head.reference(url),
            reference.contains("refs") else { return false }
        return true
    }
    
    private class func open(_ url: URL) throws -> Repository {
        if repository(url) {
            return Repository(url)
        }
        throw Failure.Repository.invalid
    }
}
