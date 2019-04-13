import AppKit

class List: NSScrollView {
    private weak var warning: NSImageView!
    private weak var message: Label!
    private weak var start: Button!
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
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
        
        let warning = NSImageView()
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.image = NSImage(named: "not")
        warning.imageScaling = .scaleNone
        warning.isHidden = true
        documentView!.addSubview(warning)
        self.warning = warning
        
        let message = Label()
        message.font = .light(14)
        message.textColor = NSColor(white: 1, alpha: 0.5)
        message.alignment = .center
        message.isHidden = true
        documentView!.addSubview(message)
        self.message = message
        
        let start = Button(.local("List.start"), color: .black, target: App.shared, action: #selector(App.shared.start))
        start.layer!.backgroundColor = NSColor.halo.cgColor
        start.isHidden = true
        start.width.constant = 90
        start.height.constant = 40
        documentView!.addSubview(start)
        self.start = start
        
        warning.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        warning.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        warning.widthAnchor.constraint(equalToConstant: 42).isActive = true
        warning.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 25).isActive = true
        message.widthAnchor.constraint(equalToConstant: 280).isActive = true
        
        start.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        start.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update() {
        isHidden = false
        App.shared.repository == nil ? not() : load()
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
    
    private func not() {
        warning.isHidden = false
        message.isHidden = false
        start.isHidden = false
        message.stringValue = .local("List.not")
    }
    
    private func load() {
        warning.isHidden = true
        message.isHidden = true
        start.isHidden = true
        documentView!.subviews.forEach { ($0 as? Item)?.removeFromSuperview() }
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
