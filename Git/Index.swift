import Foundation

class Index {
    struct Entry {
        fileprivate(set) var created = Date()
        fileprivate(set) var modified = Date()
        fileprivate(set) var id = ""
        fileprivate(set) var url = URL(fileURLWithPath: "")
        fileprivate(set) var size = 0
        fileprivate(set) var device = 0
        fileprivate(set) var inode = 0
        fileprivate(set) var mode = 33188
        fileprivate(set) var user = 0
        fileprivate(set) var group = 0
        fileprivate(set) var conflicts = false
    }
    
    struct Tree {
        fileprivate(set) var id = ""
        fileprivate(set) var url = URL(fileURLWithPath: "")
        fileprivate(set) var entries = 0
        fileprivate(set) var subtrees = 0
    }
    
    private(set) var id = ""
    private(set) var version = 2
    private(set) var entries = [Entry]()
    private(set) var trees = [Tree]()
    
    init() { }
    
    init?(_ url: URL) {
        guard
            let parse = Parse(url.appendingPathComponent(".git/index")),
            "DIRC" == (try? parse.string()),
            let version = try? parse.number(),
            let count = try? parse.number(),
            let entries = try? (0 ..< count).map({ _ in try entry(parse, url: url) }),
            let tree = try? trees(parse, url: url),
            let id = try? parse.hash(),
            parse.index == parse.data.count
        else { return nil }
        self.version = version
        self.entries = entries
        self.trees = tree
        self.id = id
    }
    
    func entry(_ id: String, url: URL) {
        var entry = Entry()
        entry.id = id
        entry.url = url
        entry.size = try! Data(contentsOf: url).count
        entries.append(entry)
    }
    
    func save(_ url: URL) {
        let serial = Serial()
        serial.string("DIRC")
        serial.number(UInt32(version))
        serial.number(UInt32(entries.count))
        entries.sorted(by: { $0.url.path < $1.url.path }).forEach {
            serial.date($0.created)
            serial.date($0.modified)
            serial.number(UInt32($0.device))
            serial.number(UInt32($0.inode))
            serial.number(UInt32($0.mode))
            serial.number(UInt32($0.user))
            serial.number(UInt32($0.group))
            serial.number(UInt32($0.size))
            serial.hex($0.id)
            serial.number(UInt16($0.url.path.dropFirst(url.path.count + 1).count))
            serial.nulled(String($0.url.path.dropFirst(url.path.count + 1)))
        }
        if !trees.isEmpty {
            let trees = Serial()
            self.trees.sorted(by: { $0.url.path < $1.url.path }).forEach {
                trees.nulled(String($0.url.path.dropFirst(url.path.count + 1)))
                trees.string("\($0.entries) ")
                trees.string("\($0.subtrees)\n")
                trees.hex($0.id)
            }
            serial.string("TREE")
            serial.number(UInt32(trees.data.count))
            serial.serial(trees)
        }
        serial.hash()
        try? serial.data.write(to: url.appendingPathComponent(".git/index"), options: .atomic)
    }
    
    private func entry(_ parse: Parse, url: URL) throws -> Entry {
        var entry = Entry()
        entry.created = try parse.date()
        entry.modified = try parse.date()
        entry.device = try parse.number()
        entry.inode = try parse.number()
        entry.mode = try parse.number()
        entry.user = try parse.number()
        entry.group = try parse.number()
        entry.size = try parse.number()
        entry.id = try parse.hash()
        entry.conflicts = try parse.conflict()
        entry.url = url.appendingPathComponent(try parse.name())
        return entry
    }
    
    private func trees(_ parse: Parse, url: URL) throws -> [Tree] {
        let limit = (try parse.tree())
        var result = [Tree]()
        while parse.index < limit { result.append(try tree(parse, url: url)) }
        return result
    }
    
    private func tree(_ parse: Parse, url: URL) throws -> Tree {
        var tree = Tree()
        tree.url = url.appendingPathComponent(try parse.variable())
        tree.entries = try {
            if $0 == nil { throw Failure.Index.malformed }
            return $0!
        } (Int(try parse.ascii(" ")))
        tree.subtrees = try {
            if $0 == nil { throw Failure.Index.malformed }
            return $0!
        } (Int(try parse.ascii("\n")))
        tree.id = try parse.hash()
        return tree
    }
}
