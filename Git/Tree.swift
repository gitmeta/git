import Foundation

class Tree {
    class Item {
        var id = ""
        var url = URL(fileURLWithPath: "")
        required init() { }
    }
    
    class Blob: Item { }
    class Sub: Item { }
    
    private(set) var items = [Item]()
    private static let map: [String: Item.Type] = ["100644": Blob.self, "100755": Blob.self, "40000": Sub.self]
    
    init(_ data: Data, url: URL) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        while parse.index < data.count {
            guard let item = Tree.map[try parse.ascii(" ")]?.init() else { throw Failure.Tree.unreadable }
            item.url = url.appendingPathComponent(try parse.variable())
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
                item.url = $0.resolvingSymlinksInPath()
                item.id = hash.file($0).1
                items.append(item)
            }
        }
    }
    
    @discardableResult func save(_ url: URL) -> String {
        let serial = Serial()
        items.sorted(by: { $0.url.path.compare($1.url.path, options: .caseInsensitive) != .orderedDescending })
            .forEach { item in
            serial.string("\(Tree.map.first(where: { $0.1 == type(of: item) })!.key) ")
            serial.nulled(String(item.url.path.dropFirst(url.path.count + 1)))
            serial.hex(item.id)
        }
        let hash = Hash().tree(serial.data)
        let directory = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try! Press().compress(hash.0).write(to: directory.appendingPathComponent(String(hash.1.dropFirst(2))),
                                            options: .atomic)
        return hash.1
    }
}
