import Git
import AppKit

class List: NSScrollView {
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    private var items: [Item] { return documentView!.subviews as! [Item] }
    private let timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
    
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
        
        timer.resume()
        timer.setEventHandler { App.shared.repository?.status { [weak self] in self?.merge($0) } }
        timer.schedule(deadline: .now(), repeating: 3)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func merge(_ items: [(URL, Status)]) {
        self.items.filter({ item in !items.contains(where: { $0.0 == item.url }) }).forEach { $0.remove() }
        var previous: Item?
        items.forEach { item in
            if let exists = self.items.first(where: { $0.url == item.0 }) {
                exists.disconnect()
                exists.connect(previous)
                exists.status(item.1)
                previous = exists
            } else {
                let new = Item(item.0)
                new.status(item.1)
                documentView!.addSubview(new)
                
                new.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                new.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                new.connect(previous)
                previous = new
            }
        }
        bottom = documentView!.bottomAnchor.constraint(
            greaterThanOrEqualTo: previous?.bottomAnchor ?? bottomAnchor, constant: 20)
    }
}

private class Flipped: NSView { override var isFlipped: Bool { return true } }
