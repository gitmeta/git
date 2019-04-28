import Foundation

class Tree {
    class Item {
        var id = ""
        var url = URL(fileURLWithPath: "")
        var category: Category { return .unknown }
    }
    
    class Blob: Item {
        override var category: Tree.Category { return .blob }
    }
    
    class Sub: Item, Hashable {
        static func == (lhs: Tree.Sub, rhs: Tree.Sub) -> Bool { return lhs.id == rhs.id }
        override var category: Tree.Category { return .sub }
        func hash(into: inout Hasher) { into.combine(id) }
    }
    
    enum Category: String {
        case unknown
        case blob = "100644"
        case sub = "40000"
        
        func make() -> Item {
            switch self {
            case .sub: return Sub()
            default: return Blob()
            }
        }
    }
    
    private(set) var items = [Item]()
    private(set) var children = [Sub: Tree]()
    private let hasher = Hash()
    
    convenience init(_ id: String, url: URL, trail: URL? = nil) throws {
        try self.init(Press().decompress(try Data(contentsOf:
            url.appendingPathComponent(".git/objects/\(id.prefix(2))/\(id.dropFirst(2))"))), url: trail ?? url)
    }
    
    init(_ data: Data, url: URL) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        while parse.index < data.count {
            let item = (Category(rawValue: try parse.ascii(" ")) ?? .blob).make()
            item.url = url.appendingPathComponent(try parse.variable())
            item.id = try parse.hash()
            items.append(item)
        }
    }
    
    init(_ url: URL, ignore: Ignore, update: [URL], entries: [Index.Entry]) {
        try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).forEach {
            let content = $0.resolvingSymlinksInPath()
            if content.hasDirectoryPath {
                let child = Tree(content, ignore: ignore, update: update, entries: entries)
                if !child.items.isEmpty {
                    let item = Sub()
                    item.url = content
                    item.id = child.hash.1
                    items.append(item)
                    children[item] = child
                }
            } else if !ignore.url(content) {
                if update.contains(where: { $0.path == content.path }) {
                    let item = Blob()
                    item.url = content
                    item.id = hasher.file(content).1
                    items.append(item)
                } else if let entry = entries.first(where: { $0.url.path == content.path }) {
                    let item = Blob()
                    item.url = entry.url
                    item.id = entry.id
                    items.append(item)
                }
            }
        }
    }
    
    func list(_ url: URL) -> [Item] {
        return items.flatMap { $0 is Blob ? [$0] : (try? Tree($0.id, url: url, trail: $0.url))?.list(url) ?? [] }
    }
    
    @discardableResult func save(_ url: URL) -> String {
        children.values.forEach({ $0.save(url) })
        let hash = self.hash
        let directory = url.appendingPathComponent(".git/objects/\(hash.1.prefix(2))")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try! Press().compress(hash.0).write(to: directory.appendingPathComponent(String(hash.1.dropFirst(2))),
                                            options: .atomic)
        return hash.1
    }
    
    private var hash: (Data, String) {
        let serial = Serial()
        items.sorted(by:
        { $0.url.path.compare($1.url.path, options: .caseInsensitive) != .orderedDescending }).forEach {
            serial.string($0.category.rawValue + " ")
            serial.nulled($0.url.lastPathComponent)
            serial.hex($0.id)
        }
        return hasher.tree(serial.data)
    }
}
