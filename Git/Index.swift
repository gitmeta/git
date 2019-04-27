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
        entries.removeAll(where: { $0.url.path == url.path })
        entries.append(entry)
    }
    
    func main(_ id: String, url: URL, tree: Tree) {
        directories = directories(id, url: url, tree: tree).reversed()
    }
    
    func save(_ url: URL) {
        let serial = Serial()
        serial.string("DIRC")
        serial.number(UInt32(version))
        serial.number(UInt32(entries.count))
        entries.sorted(by: { $0.url.path.compare($1.url.path, options: .caseInsensitive) != .orderedDescending }).forEach {
            serial.date($0.created)
            serial.date($0.modified)
            serial.number(UInt32($0.device))
            serial.number(UInt32($0.inode))
            serial.number(UInt32($0.mode))
            serial.number(UInt32($0.user))
            serial.number(UInt32($0.group))
            serial.number(UInt32($0.size))
            serial.hex($0.id)
            serial.number(UInt8(0))
            
            let name = String($0.url.path.dropFirst(url.path.count + 1))
            var size = name.count
            serial.number(UInt8(size))
            serial.nulled(name)
            while (size + 7) % 8 != 0 {
                serial.string("\u{0000}")
                print("add nil")
                size += 1
            }
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
    
    private func directories(_ id: String, url: URL, tree: Tree) -> [Directory] {
        var directory = Directory()
        directory.id = id
        directory.url = url
        directory.entries = tree.items.filter({ $0 is Tree.Blob }).count
        var result = [Directory]()
        tree.children.sorted(by: { $0.0.url.path.compare($1.0.url.path, options:
            .caseInsensitive) == .orderedDescending }).forEach {
                let child = directories($0.0.id, url: $0.0.url, tree: $0.1)
                directory.entries += child.last!.entries
                directory.sub += 1
                result.append(contentsOf: child)
        }
        result.append(directory)
        return result
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
