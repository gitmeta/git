import Foundation

public class Commit {
    public class User {
        var name = ""
        var email = ""
        var date = Date()
        
        init() { }
        
        fileprivate init(_ string: String) throws {
            let first = string.components(separatedBy: " <")
            let second = first.last?.components(separatedBy: "> ")
            let third = second?.last?.components(separatedBy: " ")
            guard
                first.count == 2,
                second?.count == 2,
                third?.count == 2,
                let name = first.first?.components(separatedBy: " "),
                name.count == 2,
                let date = TimeInterval(third![0])
            else { throw Failure.Commit.unreadable }
            self.name = name[1]
            self.email = second![0]
            self.date = Date(timeIntervalSince1970: date)
        }
    }
    
    var author = User()
    var committer = User()
    var tree = ""
    var message = ""
    var parent: String?
    
    init(_ data: Data) throws {
        let string = String(decoding: data, as: UTF8.self)
        let split = string.components(separatedBy: "\n\n")
        let lines = split.first!.components(separatedBy: "\n")
        guard
            split.count == 2,
            lines.count == 3 || lines.count == 4,
            let tree = lines[0].components(separatedBy: "tree ").last,
            tree.count == 40,
            let author = try? User(lines[lines.count - 2]),
            let committer = try? User(lines[lines.count - 1])
        else { throw Failure.Commit.unreadable }
        if lines.count == 4 {
            guard let parent = lines[1].components(separatedBy: "parent ").last, parent.count == 40
                else { throw Failure.Commit.unreadable }
            self.parent = parent
        }
        self.tree = tree
        self.author = author
        self.committer = committer
    }
    
    init() { }
    
    var serial: String {
        return ""
    }
}
