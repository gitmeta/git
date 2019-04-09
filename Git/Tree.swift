import Foundation

struct Tree {
    struct Blob: TreeItem {
        var id = String()
        var name = String()
    }
    
    struct Tree: TreeItem {
        var id = String()
        var name = String()
    }
    
    private(set) var items = [TreeItem]()
    
    init(_ data: Data) throws {
        let parse = Parse(data)
        guard "tree" == (try? parse.ascii(" ")) else { throw Failure.Tree.unreadable }
        _ = try parse.variable()
        while parse.index < data.count {
            var item: TreeItem
            switch try parse.ascii(" ") {
            case "100644": item = Blob()
            case "40000": item = Tree()
            default: throw Failure.Tree.unreadable
            }
            item.name = try parse.variable()
            item.id = try parse.hash()
            items.append(item)
        }
    }
}

protocol TreeItem {
    var id: String { get set }
    var name: String { get set }
}
