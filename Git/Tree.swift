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
    
    convenience init(_ id: String, url: URL, trail: URL? = nil) throws {
        try self.init(Hub.content.get(id, url: url), url: trail ?? url)
    }
    
    convenience init(_ data: Data, url: URL) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        try self.init(parse, url: url)
    }
    
    convenience init(_ data: Data) throws {
        try self.init(Parse(data), url: URL(fileURLWithPath: ""))
    }
    
    init(_ url: URL, ignore: Ignore, update: [URL], entries: [Index.Entry]) {
        try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).forEach {
            let content = $0.resolvingSymlinksInPath()
            if content.hasDirectoryPath {
                let child = Tree(content, ignore: ignore, update: update, entries: entries)
                if !child.items.isEmpty {
                    let item = Sub()
                    item.url = content
                    item.id = Hub.hash.tree(child.serial).1
                    items.append(item)
                    children[item] = child
                }
            } else if !ignore.url(content) {
                if update.contains(where: { $0.path == content.path }) {
                    let item = Blob()
                    item.url = content
                    item.id = Hub.hash.file(content).1
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
    
    private init(_ parse: Parse, url: URL) throws {
        while parse.index < parse.data.count {
            let item = (Category(rawValue: try parse.ascii(" ")) ?? .blob).make()
            item.url = url.appendingPathComponent(try parse.variable())
            item.id = try parse.hash()
            items.append(item)
        }
    }
    
    func list(_ url: URL) -> [Item] {
        return items.flatMap { $0 is Blob ? [$0] : (try? Tree($0.id, url: url, trail: $0.url))?.list(url) ?? [] }
    }
    
    @discardableResult func save(_ url: URL) throws -> String {
        try children.values.forEach({ try $0.save(url) })
        return try Hub.content.add(self, url: url)
    }
    
    var serial: Data {
        let serial = Serial()
        items.sorted(by: { $0.url.path.compare($1.url.path) != .orderedDescending }).forEach {
            serial.string($0.category.rawValue + " ")
            serial.nulled($0.url.lastPathComponent)
            serial.hex($0.id)
        }
        return serial.data
    }
}
