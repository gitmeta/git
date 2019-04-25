import Foundation

public class Commit {
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
            split.count > 1,
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
        self.message = split.dropFirst().joined(separator: "\n\n")
    }
    
    init() { }
    
    var serial: String {
        var result = "tree \(tree)\n"
        if let parent = self.parent {
            result += "parent \(parent)\n"
        }
        result += "author \(author.serial)\ncommitter \(committer.serial)\n\n\(message)\n"
        return result
    }
    
    @discardableResult func save(_ url: URL) -> String {
        let hash = Hash().commit(serial)
        let directory = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try! Press().compress(hash.0).write(to: directory.appendingPathComponent(String(hash.1.dropFirst(2))),
                                            options: .atomic)
        let head = String(decoding: try! Data(contentsOf: url.appendingPathComponent(".git/HEAD")), as: UTF8.self).dropFirst(5)
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git/" + head).deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try! Data(hash.1.utf8).write(to: url.appendingPathComponent(".git/" + head), options: .atomic)
        return hash.1
    }
}
