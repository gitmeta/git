import Foundation

public final class Session: Codable {
    public internal(set) var url = URL(fileURLWithPath: "")
    public internal(set) var bookmark = Data()
    public internal(set) var name = ""
    public internal(set) var email = ""
    
    public func load(_ result: (() -> Void)? = nil) {
        Hub.dispatch.background({ [weak self] in
            guard let data = UserDefaults.standard.data(forKey: "session"),
                let decoded = try? JSONDecoder().decode(Session.self, from: data)
            else { return }
            self?.name = decoded.name
            self?.email = decoded.email
            self?.url = decoded.url
            self?.bookmark = decoded.bookmark
        }, success: result ?? { })
    }
    
    public func update(_ name: String, email: String, error: ((Error) -> Void)? = nil, done: (() -> Void)? = nil) {
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
        }, error: error ?? { _ in }, success: done ?? { })
    }
    
    public func update(_ url: URL, bookmark: Data, done: (() -> Void)? = nil) {
        Hub.dispatch.background({ [weak self] in
            self?.url = url
            self?.bookmark = bookmark
            self?.save()
        }, success: done ?? { })
    }
    
    func save() { UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session") }
}
