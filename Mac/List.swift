import Git
import AppKit

class List: NSScrollView {
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        drawsBackground = false
        hasVerticalScroller = true
        verticalScroller!.controlSize = .mini
        verticalScrollElasticity = .allowed
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update(_ items: [(URL, Status)]) {
        var before = documentView!.subviews as! [Item]
        var last: Item?
        items.forEach { item in
            let new: Item
            if let index = before.firstIndex(where: { $0.url == item.0 }) {
                new = before.remove(at: index)
                new.disconnect()
            } else {
                new = Item(item.0)
                documentView!.addSubview(new)
        
                new.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                new.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            }
            new.status(item.1)
            new.connect(last)
            last = new
        }
        bottom = documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: last?.bottomAnchor ?? bottomAnchor, constant: 20)
        before.forEach({ $0.removeFromSuperview() })
    }
}
