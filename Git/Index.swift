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
    
    struct Directory {
        fileprivate(set) var id = ""
        fileprivate(set) var url = URL(fileURLWithPath: "")
        fileprivate(set) var entries = 0
        fileprivate(set) var sub = 0
    }
    
    private(set) var id = ""
    private(set) var version = 2
    private(set) var entries = [Entry]()
    private(set) var directories = [Directory]()
    
    init() { }
    
    init?(_ url: URL) {
        guard
            let parse = Parse(url.appendingPathComponent(".git/index")),
            "DIRC" == (try? parse.string()),
            let version = try? parse.number(),
            let count = try? parse.number(),
            let entries = try? (0 ..< count).map({ _ in try entry(parse, url: url) }),
            let directories = try? directories(parse, url: url),
            let id = try? parse.hash(),
            parse.index == parse.data.count
        else { return nil }
        self.version = version
        self.entries = entries
        self.directories = directories
        self.id = id
    }
    
    func entry(_ id: String, url: URL) {
        var entry = Entry()
        entry.id = id
        entry.url = url
        entry.size = try! Data(contentsOf: url).count
        entries.append(entry)
    }
    
    func directory(_ id: String, url: URL, tree: Tree) {
        directories.append(Directory(id: id, url: url, entries: tree.items.filter({ $0 is Tree.Blob }).count,
                                     sub: tree.items.filter({ $0 is Tree.Sub }).count))
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
        if !directories.isEmpty {
            let trees = Serial()
            self.directories.sorted(by: { $0.url.path < $1.url.path }).forEach {
                trees.nulled(String($0.url.path.dropFirst(url.path.count + 1)))
                trees.string("\($0.entries) ")
                trees.string("\($0.sub)\n")
                trees.hex($0.id)
            }
            serial.string("TREE")
            serial.number(UInt32(trees.data.count))
            serial.serial(trees)
        }
        serial.hash()
        try! serial.data.write(to: url.appendingPathComponent(".git/index"), options: .atomic)
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
    
    private func directories(_ parse: Parse, url: URL) throws -> [Directory] {
        let limit = (try parse.tree())
        var result = [Directory]()
        while parse.index < limit { result.append(try directory(parse, limit: limit, url: url)) }
        return result
    }
    
    private func directory(_ parse: Parse, limit: Int, url: URL) throws -> Directory {
        var tree = Directory()
        tree.url = {
            $0.isEmpty ? url : url.appendingPathComponent($0)
        } (try parse.variable())
        
        if parse.index < limit {
            tree.entries = try {
                if $0 == nil { throw Failure.Index.malformed }
                return $0!
            } (Int(try parse.ascii(" ")))
            
            if parse.index < limit {
                tree.sub = try {
                    if $0 == nil { throw Failure.Index.malformed }
                    return $0!
                } (Int(try parse.ascii("\n")))
                
                if parse.index < limit {
                    if tree.entries == -1 {
                        print("contains nil")
                    } else {
                        print("not nil")
                        tree.id = try parse.hash()
                    }
                    print("yes \(tree.id) \(tree.url.lastPathComponent) \(tree.entries) \(tree.sub)")
                } else {
                    print("none")
                }
            }
        }
        return tree
    }
}
