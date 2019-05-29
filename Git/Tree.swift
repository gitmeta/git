import Foundation

final class Tree {
    enum Category: String {
        case blob = "100644"
        case exec = "100755"
        case tree = "40000"
        case unknown
    }
    
    final class Item {
        var id = ""
        var url = URL(fileURLWithPath: "")
        var category = Category.unknown
    }
    
    private(set) var items = [Item]()
    private(set) var children = [String: Tree]()
    
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
                    let item = Item()
                    item.category = .tree
                    item.url = content
                    item.id = Hub.hash.tree(child.serial).1
                    items.append(item)
                    children[item.id] = child
                }
            } else if !ignore.url(content) {
                if update.contains(where: { $0.path == content.path }) {
                    let item = Item()
                    item.category = .blob
                    item.url = content
                    item.id = Hub.hash.file(content).1
                    items.append(item)
                } else if let entry = entries.first(where: { $0.url.path == content.path }) {
                    let item = Item()
                    item.category = .blob
                    item.url = entry.url
                    item.id = entry.id
                    items.append(item)
                }
            }
        }
    }
    
    private init(_ parse: Parse, url: URL) throws {
        while parse.index < parse.data.count {
            let item = Item()
            item.category = Category(rawValue: try parse.ascii(" ")) ?? .unknown
            item.url = url.appendingPathComponent(try parse.variable())
            item.id = try parse.hash()
            items.append(item)
        }
    }
    
    func list(_ url: URL) -> [Item] {
        return items.flatMap { $0.category != .tree ? [$0] : (try? Tree($0.id, url: url, trail: $0.url))?.list(url) ?? [] }
    }
    
    func map(_ index: Index, url: URL) throws {
        try items.forEach {
            if $0.category == .tree {
                try Tree($0.id, url: url, trail: $0.url).map(index, url: url)
            } else {
                index.entry($0.id, url: $0.url)
            }
        }
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
