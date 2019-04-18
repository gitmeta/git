import Foundation

class Tree {
    class Item {
        var id = ""
        var name = ""
        required init() { }
    }
    
    class Blob: Item { }
    class Sub: Item { }
    
    private(set) var items = [Item]()
    private static let map: [String: Item.Type] = ["100644": Blob.self, "40000": Sub.self]
    
    class func save(_ url: URL) -> String {
        let tree = Tree(url)
        let serial = Serial()
        tree.items.sorted(by: { $0.name < $1.name }).forEach { item in
            serial.string("\(Tree.map.first(where: { $0.1 == type(of: item) })!.key) ")
            serial.nulled(item.name)
            serial.hex(item.id)
        }
        let hash = Hash().tree(serial.data)
        let directory = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try! Press().compress(hash.0).write(to: directory.appendingPathComponent(String(hash.1.dropFirst(2))),
                                               options: .atomic)
        return hash.1
    }
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        while parse.index < data.count {
            guard let item = Tree.map[try parse.ascii(" ")]?.init() else { throw Failure.Tree.unreadable }
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
}
