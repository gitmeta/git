import Foundation

class Tree {
    class Item {
        var id = String()
        var name = String()
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
}
