import Foundation

public class User {
    public var name = ""
    public var email = ""
    var timezone = ""
    var date = Date()
    
    public init(_ name: String, email: String) throws {
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
        
        self.name = name
        self.email = email
    }
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "xx"
        timezone = {
            $0.dateFormat = "xx"
            return $0.string(from: date)
        } (DateFormatter())
    }
    
    init(_ string: String) throws {
        let first = string.components(separatedBy: " <")
        let second = first.last?.components(separatedBy: "> ")
        let third = second?.last?.components(separatedBy: " ")
        guard
            first.count == 2,
            second?.count == 2,
            third?.count == 2,
            let names = first.first?.components(separatedBy: " "),
            names.count > 1,
            let seconds = TimeInterval(third![0])
            else { throw Failure.Commit.unreadable }
        name = names.dropFirst().joined(separator: " ")
        email = second![0]
        date = Date(timeIntervalSince1970: seconds)
        timezone = third![1]
    }
    
    var serial: String { return "\(name) <\(email)> \(Int(date.timeIntervalSince1970)) \(timezone)" }
}
