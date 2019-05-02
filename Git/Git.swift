import Foundation

public class Git {
    public static var session = Session()
    private static let dispatch = Dispatch()
    
    public class func repository(_ url: URL, result: @escaping((Bool) -> Void)) {
        dispatch.background({ repository(url) }, success: result)
    }
    
    public class func create(_ url: URL, error: ((Error) -> Void)? = nil, result: ((Repository) -> Void)? = nil) {
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
        }, error: error, success: result ?? { _ in })
    }
    
    public class func open(_ url: URL, error: ((Error) -> Void)? = nil, result: @escaping((Repository) -> Void)) {
        dispatch.background({
            return try open(url)
        }, error: error, success: result)
    }
    
    public class func delete(_ repository: Repository, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        dispatch.background({
            try FileManager.default.removeItem(at: repository.url.appendingPathComponent(".git"))
        }, error: error, success: done ?? { })
    }
    
    public class func loadSession(_ result: @escaping(() -> Void)) {
        dispatch.background({ session = Session.load() }, success: result)
    }
    
    public class func update(_ name: String, email: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
        dispatch.background({
            guard !name.isEmpty else { throw Failure.User.name }
            
            try name.forEach {
                switch $0 {
                case "<", ">", "\n", "\t": throw Failure.User.name
                default: break
                }
            }
            
            try email.forEach {
                switch $0 {
                case " ", "*", "\\", "/", "$", "%", ";", ",", "!", "?", "~", "<", ">", "\n", "\t": throw Failure.User.email
                default: break
                }
            }
            
            let at = email.components(separatedBy: "@")
            let dot = at.last!.components(separatedBy: ".")
            guard at.count == 2, dot.count > 1, !dot.first!.isEmpty, !dot.last!.isEmpty else { throw Failure.User.email }
            
            session.name = name
            session.email = email
            Session.update(session)
        }, error: error, success: done ?? { })
    }
    
    public class func update(_ url: URL, bookmark: Data, done: (() -> Void)? = nil) {
        dispatch.background({
            session.url = url
            session.bookmark = bookmark
            Session.update(session)
        }, success: done ?? { })
    }
    
    private class func repository(_ url: URL) -> Bool {
        var d: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/refs").path, isDirectory: &d),
            d.boolValue,
            FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects").path, isDirectory: &d),
            d.boolValue,
            let head = try? Data(contentsOf: url.appendingPathComponent(".git/HEAD")),
            String(decoding: head, as: UTF8.self).contains("ref: refs/") else { return false }
        return true
    }
    
    private class func open(_ url: URL) throws -> Repository {
        if repository(url) {
            return Repository(url)
        }
        throw Failure.Repository.invalid
    }
}
