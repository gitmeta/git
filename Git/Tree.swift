import Foundation

class Tree {
    class Item {
        var id = ""
        var name = ""
    }
    
    class Blob: Item { }
    class Sub: Item { }
    
    private(set) var items = [Item]()
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        while parse.index < data.count {
            let item: Item
            switch try parse.ascii(" ") {
            case "100644": item = Blob()
            case "40000": item = Sub()
            default: throw Failure.Tree.unreadable
            }
            item.name = try parse.variable()
            item.id = try parse.hash()
            items.append(item)
        }
    }
    
    init(_ url: URL) {
        let hash = Hash()
        try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).forEach {
            if $0.hasDirectoryPath {
                if $0.lastPathComponent != ".git" {
                    
                }
            } else {
                let item = Blob()
                item.name = String($0.resolvingSymlinksInPath().path.dropFirst(url.path.count + 1))
                item.id = hash.file($0).1
                items.append(item)
            }
        }
    }
    
    func save(_ url: URL) {/*
        let blob = Git.Blob()
        blob.nu
        items.sorted(by: { $0.name < $1.name }).forEach {
            
        }
        blob.number(UInt32(version))
        blob.number(UInt32(entries.count))
        entries.sorted(by: { $0.url.path < $1.url.path }).forEach {
            blob.date($0.created)
            blob.date($0.modified)
            blob.number(UInt32($0.device))
            blob.number(UInt32($0.inode))
            blob.number(UInt32($0.mode))
            blob.number(UInt32($0.user))
            blob.number(UInt32($0.group))
            blob.number(UInt32($0.size))
            blob.hex($0.id)
            blob.number(UInt16($0.url.path.dropFirst(url.path.count + 1).count))
            blob.nulled(String($0.url.path.dropFirst(url.path.count + 1)))
        }
        if !trees.isEmpty {
            let trees = Blob()
            self.trees.sorted(by: { $0.url.path < $1.url.path }).forEach {
                trees.nulled(String($0.url.path.dropFirst(url.path.count + 1)))
                trees.string("\($0.entries) ")
                trees.string("\($0.subtrees)\n")
                trees.hex($0.id)
            }
            blob.string("TREE")
            blob.number(UInt32(trees.data.count))
            blob.blob(trees)
        }
        blob.hash()
        try? blob.data.write(to: url.appendingPathComponent(".git/index"), options: .atomic)*/
    }
}
