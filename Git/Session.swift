import Foundation

public struct Session: Codable {
    static func update(_ session: Session) {
        UserDefaults.standard.set(try! JSONEncoder().encode(session), forKey: "session")
    }
    
    static func load() -> Session {
        return {
            $0 == nil ? Session() : try! JSONDecoder().decode(Session.self, from: $0!)
        } (UserDefaults.standard.data(forKey: "session"))
    }
    
    public internal(set) var url = URL(fileURLWithPath: "")
    public internal(set) var bookmark = Data()
    public internal(set) var name = ""
    public internal(set) var email = ""
}
