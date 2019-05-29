import Git
import AppKit

final class Home: NSWindow  {
    enum State {
        case loading
        case ready
        case packed
        case create
    }
    
    final class Item: NSView {
        let url: URL
        private(set) weak var check: Button.Check!
        private weak var badge: NSView!
        private weak var label: Label!
        override var isOpaque: Bool { return true }
        override var wantsDefaultClipping: Bool { return false }
        
        fileprivate init(_ url: URL, status: Status) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.attributedStringValue = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string: "\(path) ", attributes: [.font: NSFont.light(12), .foregroundColor:
                        NSColor.halo.withAlphaComponent(0.9)]))
                }
                $0.append(NSAttributedString(string: url.lastPathComponent, attributes: [.font: NSFont.bold(12), .foregroundColor: NSColor.halo]))
                return $0
            } (NSMutableAttributedString())
            label.maximumNumberOfLines = 1
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            let badge = NSView()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.wantsLayer = true
            badge.layer!.cornerRadius = 4
            addSubview(badge)
            self.badge = badge
            
            let hashtag = Label()
            hashtag.textColor = .black
            hashtag.font = .systemFont(ofSize: 10, weight: .light)
            addSubview(hashtag)
            
            let check = Button.Check(self, action: #selector(change))
            check.off = NSImage(named: "checkOff")
            check.on = NSImage(named: "checkOn")
            check.checked = true
            addSubview(check)
            self.check = check
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = .black
            addSubview(border)
            
            switch status {
            case .deleted:
                badge.layer!.backgroundColor = NSColor.deleted.cgColor
                hashtag.stringValue = .local("Home.deleted")
            case .added:
                badge.layer!.backgroundColor = NSColor.added.cgColor
                hashtag.stringValue = .local("Home.added")
            case .modified:
                badge.layer!.backgroundColor = NSColor.modified.cgColor
                hashtag.stringValue = .local("Home.modified")
            case .untracked:
                badge.layer!.backgroundColor = NSColor.untracked.cgColor
                hashtag.stringValue = .local("Home.untracked")
            }
            
            heightAnchor.constraint(equalToConstant: 46).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: check.leftAnchor, constant: -4).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 32).isActive = true
            check.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            check.topAnchor.constraint(equalTo: topAnchor).isActive = true
            check.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        @objc private func change() {
            app.home.countItems()
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                label.alphaValue = check.checked ? 1 : 0.4
                badge.alphaValue = check.checked ? 1 : 0.3
            }) { }
        }
    }
    
    private(set) weak var directory: Button.Text!
    private(set) weak var list: NSScrollView!
    private weak var count: Label!
    private weak var image: NSImageView!
    private weak var button: Button.Text!
    private weak var label: Label!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 600) / 2, y: (NSScreen.main!.frame.height - 600) / 2, width: 600, height: 600),
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 100)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let left = NSView()
        left.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(left)
        
        let borderLeft = NSView()
        borderLeft.translatesAutoresizingMaskIntoConstraints = false
        borderLeft.wantsLayer = true
        borderLeft.layer!.backgroundColor = .black
        left.addSubview(borderLeft)
        
        let top = NSView()
        top.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(top)
        
        let borderTop = NSView()
        borderTop.translatesAutoresizingMaskIntoConstraints = false
        borderTop.wantsLayer = true
        borderTop.layer!.backgroundColor = .black
        top.addSubview(borderTop)
        
        let add = Button.Image(app, action: #selector(app.add))
        add.image.image = NSImage(named: "add")
        
        let reset = Button.Image(app, action: #selector(app.reset))
        reset.image.image = NSImage(named: "reset")
        
        let cloud = Button.Image(self, action: nil)
        cloud.image.image = NSImage(named: "cloud")
        
        let history = Button.Image(app, action: #selector(app.history))
        history.image.image = NSImage(named: "history")
        
        let settings = Button.Image(app, action: #selector(app.settings))
        settings.image.image = NSImage(named: "settings")
        
        let directory = Button.Text(app, action: #selector(app.browse))
        directory.label.stringValue = .local("Home.directory")
        directory.label.font = .systemFont(ofSize: 12, weight: .bold)
        directory.label.textColor = .halo
        directory.label.alignment = .left
        top.addSubview(directory)
        self.directory = directory
        
        let list: NSScrollView = NSScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.drawsBackground = false
        list.hasVerticalScroller = true
        list.verticalScroller!.controlSize = .mini
        list.verticalScrollElasticity = .allowed
        list.documentView = Flipped()
        list.documentView!.translatesAutoresizingMaskIntoConstraints = false
        list.documentView!.topAnchor.constraint(equalTo: list.topAnchor).isActive = true
        list.documentView!.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        list.documentView!.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: list.bottomAnchor).isActive = true
        contentView!.addSubview(list)
        self.list = list
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "loading")
        contentView!.addSubview(image)
        self.image = image
        
        let button = Button.Text(app, action: nil)
        button.isHidden = true
        button.label.font = .systemFont(ofSize: 11, weight: .medium)
        button.label.textColor = .black
        button.wantsLayer = true
        button.layer!.cornerRadius = 4
        button.layer!.backgroundColor = NSColor.halo.cgColor
        contentView!.addSubview(button)
        self.button = button
        
        let label = Label()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = NSColor(white: 1, alpha: 0.7)
        contentView!.addSubview(label)
        self.label = label
        
        let count = Label()
        count.font = .systemFont(ofSize: 10, weight: .light)
        count.alignment = .right
        count.textColor = NSColor(white: 1, alpha: 0.6)
        top.addSubview(count)
        self.count = count
        
        left.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 1).isActive = true
        left.widthAnchor.constraint(equalToConstant: 62).isActive = true
        left.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        left.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        borderLeft.topAnchor.constraint(equalTo: left.topAnchor, constant: 1).isActive = true
        borderLeft.bottomAnchor.constraint(equalTo: left.bottomAnchor, constant: -1).isActive = true
        borderLeft.rightAnchor.constraint(equalTo: left.rightAnchor).isActive = true
        borderLeft.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        top.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        top.heightAnchor.constraint(equalToConstant: 40).isActive = true
        top.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        borderTop.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 2).isActive = true
        borderTop.rightAnchor.constraint(equalTo: top.rightAnchor, constant: -2).isActive = true
        borderTop.bottomAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        borderTop.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        directory.topAnchor.constraint(equalTo: top.topAnchor).isActive = true
        directory.bottomAnchor.constraint(equalTo: top.bottomAnchor, constant: -3).isActive = true
        directory.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        directory.leftAnchor.constraint(equalTo: top.leftAnchor, constant: 82).isActive = true
        
        list.topAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: left.rightAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        
        image.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: list.centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        button.widthAnchor.constraint(equalToConstant: 62).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        label.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        
        count.rightAnchor.constraint(equalTo: top.rightAnchor, constant: -12).isActive = true
        count.centerYAnchor.constraint(equalTo: top.centerYAnchor).isActive = true
        
        var vertical = left.topAnchor
        [add, reset, cloud, history, settings].forEach {
            left.addSubview($0)
            $0.leftAnchor.constraint(equalTo: left.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: left.rightAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.topAnchor.constraint(equalTo: vertical, constant: vertical == left.topAnchor ? 5 : 0).isActive = true
            vertical = $0.bottomAnchor
        }
    }
    
    func update(_ state: State, items: [(URL, Status)] = []) {
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        
        var bottom = list.documentView!.topAnchor
        items.forEach {
            let item = Item($0.0, status: $0.1)
            list.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: bottom).isActive = true
            bottom = item.bottomAnchor
        }
        self.bottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottom)
        
        switch state {
        case .loading:
            image.isHidden = false
            image.image = NSImage(named: "loading")
            button.isHidden = true
            label.isHidden = true
            count.isHidden = true
        case .packed:
            image.isHidden = false
            image.image = NSImage(named: "error")
            button.isHidden = false
            button.label.stringValue = .local("Home.button.packed")
            label.isHidden = false
            label.stringValue = .local("Home.label.packed")
            count.isHidden = true
        case .ready:
            button.isHidden = true
            count.isHidden = false
            countItems()
            if items.isEmpty {
                image.isHidden = false
                image.image = NSImage(named: "updated")
                label.isHidden = false
                label.stringValue = .local("Home.label.empty")
            } else {
                image.isHidden = true
                label.isHidden = true
            }
        case .create:
            image.isHidden = false
            image.image = NSImage(named: "error")
            button.isHidden = false
            button.label.stringValue = .local("Home.button.create")
            label.isHidden = false
            label.stringValue = .local("Home.label.create")
            count.isHidden = true
        }
    }
    
    override func close() {
        super.close()
        app.terminate(nil)
    }
    
    private func countItems() {
        count.stringValue = {
            "\($0.filter({ $0.check.checked }).count)/\($0.count)"
        } (list.documentView!.subviews.compactMap({ $0 as? Item }))
    }
}
