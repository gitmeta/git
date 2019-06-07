import Foundation

public final class Session: Codable {
    public internal(set) var url = URL(fileURLWithPath: "")
    public internal(set) var bookmark = Data()
    public internal(set) var name = ""
    public internal(set) var email = ""
    public internal(set) var user = ""
    
    public func load(_ result: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            guard let data = UserDefaults.standard.data(forKey: "session"),
                let decoded = try? JSONDecoder().decode(Session.self, from: data)
            else { return }
            self?.name = decoded.name
            self?.email = decoded.email
            self?.url = decoded.url
            self?.bookmark = decoded.bookmark
            self?.user = decoded.user
        }, success: result)
    }
    
    public func update(_ name: String, email: String, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
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
            guard at.count == 2, !at.first!.isEmpty, dot.count > 1, !dot.first!.isEmpty, !dot.last!.isEmpty
            else { throw Failure.User.email }
            
            self?.name = name
            self?.email = email
            self?.save()
        }, error: error, success: done)
    }
    
    public func update(_ user: String, password: String, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background ({ [weak self] in
            self?.user = user
            self?.save()
        }, success: done)
    }
    
    public func update(_ url: URL, bookmark: Data, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            self?.url = url
            self?.bookmark = bookmark
            self?.save()
        }, success: done)
    }
    
    func save() { UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session") }
    
    var credentials: URLCredential? {
        return URLCredential(user: "vauxhall", password: "", persistence: .forSession)
    }
}
