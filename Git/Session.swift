import Foundation

public final class Session: Codable {
    public enum Purchase: String, Codable, CaseIterable {
        case cloud
    }
    
    public internal(set) var url = URL(fileURLWithPath: "")
    public internal(set) var purchase = [Purchase]()
    public internal(set) var bookmark = Data()
    public internal(set) var name = ""
    public internal(set) var email = ""
    public internal(set) var user = ""
    public internal(set) var password: String {
        get { return recover ?? "" }
        set {
            if recover == nil {
                var query = self.query
                query[kSecValueData as String] = Data(newValue.utf8)
                SecItemAdd(query as CFDictionary, nil)
            } else {
                SecItemUpdate(query as CFDictionary, [kSecValueData: Data(newValue.utf8)] as CFDictionary)
            }
        }
    }
    
    var credentials: URLCredential? { return URLCredential(user: user, password: password, persistence: .forSession) }
    
    private var recover: String? {
        var result: CFTypeRef? = [String: Any]() as CFTypeRef
        var query = self.query
        query[kSecReturnData as String] = true
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        SecItemCopyMatching(query as CFDictionary, &result)
        if let data = (result as? [String: Any])?[String(kSecValueData)] as? Data {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
    
    private var query: [String: Any] {
        return [kSecClass: kSecClassGenericPassword, kSecAttrKeyType: 42, kSecAttrAccount: "user.key", kSecAttrService: "Git"] as [String: Any]
    }
    
    public func load(_ result: @escaping(() -> Void) = { }) {
        UserDefaults.standard.removeObject(forKey: "session")
        Hub.dispatch.background({
            guard let data = UserDefaults.standard.data(forKey: "session"),
                let decoded = try? JSONDecoder().decode(Session.self, from: data)
            else { return }
            self.name = decoded.name
            self.email = decoded.email
            self.url = decoded.url
            self.bookmark = decoded.bookmark
            self.user = decoded.user
            self.purchase = decoded.purchase
        }, success: result)
    }
    
    public func update(_ name: String, email: String, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({
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
            
            self.name = name
            self.email = email
            self.save()
        }, error: error, success: done)
    }
    
    public func update(_ user: String, password: String, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background ({
            self.user = user
            self.password = password
            self.save()
        }, success: done)
    }
    
    public func update(_ url: URL, bookmark: Data, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({
            self.url = url
            self.bookmark = bookmark
            self.save()
        }, success: done)
    }
    
    public func purchase(_ id: String, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background ({
            let item = Purchase(rawValue: id.components(separatedBy: ".").last!)!
            if !self.purchase.contains(where: { $0 == item }) {
                self.purchase.append(item)
                self.save()
            }
        }, success: done)
    }
    
    func save() { UserDefaults.standard.set(try! JSONEncoder().encode(self), forKey: "session") }
}
