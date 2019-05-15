import Foundation

public struct User {
    public internal(set) var name = ""
    public internal(set) var email = ""
    public internal(set) var date = Date()
    var timezone = ""
    
    init() { }
    
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
    
    var serial: String { return "\(name) <\(email)> \(Int(date.timeIntervalSince1970)) " + (timezone.isEmpty ? {
        $0.dateFormat = "xx"
        return $0.string(from: date)
    } (DateFormatter()) : timezone) }
}
