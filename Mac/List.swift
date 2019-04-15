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
    
    func show() {
        documentView!.subviews.forEach { $0.removeFromSuperview() }
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let files = self?.contents(App.shared.url!) {
                DispatchQueue.main.async { [weak self] in
                    guard
                        let top = self?.topAnchor,
                        let last = self?.render(files, origin: top, parent: nil)
                        else { return }
                    self?.last(last)
                }
            }
        }
    }
    
    func update(_ status: Status) {
        documentView!.subviews.compactMap({ $0 as? Item }).forEach {
            if status.untracked.contains($0.url) {
                $0.untracked()
            } else if status.added.contains($0.url) {
                $0.added()
            } else if status.modified.contains($0.url) {
                $0.modified()
            } else {
                $0.none()
            }
        }
    }
    
    func expand(_ item: Item) {
        if let files = self.contents(item.url) {
            let sibling = documentView!.subviews.first(where: { item === ($0 as? Item)?.top?.secondItem }) as? Item
            guard let last = render(files, origin: item.bottomAnchor, parent: item) else { return }
            if let sibling = sibling {
                sibling.top = sibling.topAnchor.constraint(equalTo: last.bottomAnchor)
            } else {
                self.last(last)
            }
        }
    }
    
    func collapse(_ item: Item) {
        if let sibling = documentView!.subviews.compactMap({ $0 as? Item }).filter({ $0.parent !== item }).first(where:
            { ($0.top?.secondItem as? Item)?.parent === item }) {
            sibling.top = sibling.topAnchor.constraint(equalTo: item.bottomAnchor)
        } else {
            if (bottom?.secondItem as? Item)?.parent === item {
                last(item)
            }
        }
        documentView!.subviews.compactMap({ $0 as? Item }).filter({ $0.parent === item }).forEach {
            collapse($0)
            $0.removeFromSuperview()
        }
    }
    
    private func render(_ files: [URL], origin: NSLayoutYAxisAnchor, parent: Item?) -> Item? {
        return files.reduce((nil, origin)) {
            let item = Item($1, indent: parent == nil ? 0 : parent!.indent + 1)
            item.parent = parent
            item.list = self
            documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            item.top = item.topAnchor.constraint(equalTo: $0.1)
            return (item, item.bottomAnchor)
        }.0
    }
    
    private func last(_ bottom: NSView) {
        self.bottom = documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottom.bottomAnchor, constant: 20)
    }
    
    private func contents(_ url: URL) -> [URL]? {
        return try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options:
            [.skipsPackageDescendants, .skipsSubdirectoryDescendants]).sorted(by: { $0.path < $1.path })
    }
}

private class Flipped: NSView { override var isFlipped: Bool { return true } }
