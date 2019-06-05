import Foundation

public final class Commit {
    public internal(set) var author = User()
    public internal(set) var message = ""
    var committer = User()
    var parent = [String]()
    var tree = ""
    var gpg = ""
    
    convenience init(_ id: String, url: URL) throws { try self.init(Hub.content.get(id, url: url)) }
    
    init(_ data: Data) throws {
        let string = String(decoding: data, as: UTF8.self)
        let split = string.components(separatedBy: "\n\n")
        let signed = split.first!.components(separatedBy: "\ngpgsig")
        var lines = signed.first!.components(separatedBy: "\n")
        guard
            split.count > 1,
            lines.count >= 3,
            let tree = lines.removeFirst().components(separatedBy: "tree ").last,
            tree.count == 40,
            let committer = try? User(lines.removeLast()),
            let author = try? User(lines.removeLast())
        else { throw Failure.Commit.unreadable }
        while !lines.isEmpty {
            guard let parent = lines.removeFirst().components(separatedBy: "parent ").last, parent.count == 40
                else { throw Failure.Commit.unreadable }
            self.parent.append(parent)
        }
        if signed.count == 2 {
            gpg = "\ngpgsig" + signed[1]
        }
        self.tree = tree
        self.author = author
        self.committer = committer
        self.message = split.dropFirst().joined(separator: "\n\n")
    }
    
    init() { }
    
    var serial: String {
        var result = "tree \(tree)\n"
        parent.forEach {
            result += "parent \($0)\n"
        }
        result += "author \(author.serial)\ncommitter \(committer.serial)\(gpg)\n\n\(message)"
        return result
    }
}
