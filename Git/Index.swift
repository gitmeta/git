import Foundation

struct Index {
    struct Entry {
        fileprivate(set) var created = Date()
        fileprivate(set) var modified = Date()
        fileprivate(set) var id = String()
        fileprivate(set) var name = String()
        fileprivate(set) var size = 0
        fileprivate(set) var device = 0
        fileprivate(set) var inode = 0
        fileprivate(set) var user = 0
        fileprivate(set) var group = 0
        fileprivate(set) var conflicts = false
    }
    
    struct Tree {
        fileprivate(set) var id = String()
        fileprivate(set) var name = String()
        fileprivate(set) var entries = 0
        fileprivate(set) var subtrees = 0
    }
    
    private(set) var id = String()
    private(set) var version = 2
    private(set) var entries = [Entry]()
    private(set) var trees = [Tree]()
    
    static func load(_ url: URL) -> Index? {
        var index = Index()
        guard
            let parse = Parse(url.appendingPathComponent(".git/index")),
            "DIRC" == (try? parse.string()),
            let version = try? parse.number(),
            let count = try? parse.number(),
            let entries = try? (0 ..< count).map({ _ in try entry(parse) }),
            let tree = try? trees(parse),
            let id = try? parse.hash(),
            parse.index == parse.data.count
        else { return nil }
        index.version = version
        index.entries = entries
        index.trees = tree
        index.id = id
        return index
    }
    
    static func new(_ url: URL) -> Index {
        let index = Index()
        save(index, url: url)
        return index
    }
    
    static func save(_ index: Index, url: URL) {
        let blob = Blob()
        blob.string("DIRC")
        blob.number(UInt32(index.version))
        blob.number(UInt32(index.entries.count))
        index.entries.sorted(by: { $0.name < $1.name }).forEach {
            blob.date($0.created)
            blob.date($0.modified)
            blob.number(UInt32($0.device))
            blob.number(UInt32($0.inode))
            blob.number(UInt32(33188))
            blob.number(UInt32($0.user))
            blob.number(UInt32($0.group))
            blob.number(UInt32($0.size))
            blob.hex($0.id)
            blob.number(UInt16($0.name.count))
            blob.nulled($0.name)
        }
        if !index.trees.isEmpty {
            let trees = Blob()
            index.trees.sorted(by: { $0.name < $1.name }).forEach {
                trees.nulled($0.name)
                trees.string("\($0.entries) ")
                trees.string("\($0.subtrees)\n")
                trees.hex($0.id)
            }
            blob.string("TREE")
            blob.number(UInt32(trees.data.count))
            blob.blob(trees)
        }
        blob.hash()
        try? blob.data.write(to: url.appendingPathComponent(".git/index"), options: .atomic)
    }
    
    private static func entry(_ parse: Parse) throws -> Entry {
        var entry = Entry()
        entry.created = try parse.date()
        entry.modified = try parse.date()
        entry.device = try parse.number()
        entry.inode = try parse.number()
        if (try? parse.number()) != 33188 { throw Failure.Index.malformed }
        entry.user = try parse.number()
        entry.group = try parse.number()
        entry.size = try parse.number()
        entry.id = try parse.hash()
        entry.conflicts = try parse.conflict()
        entry.name = try parse.name()
        return entry
    }
    
    private static func trees(_ parse: Parse) throws -> [Tree] {
        let limit = (try parse.tree())
        var result = [Tree]()
        while parse.index < limit { result.append(try tree(parse)) }
        return result
    }
    
    private static func tree(_ parse: Parse) throws -> Tree {
        var tree = Tree()
        tree.name = try parse.variable()
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
