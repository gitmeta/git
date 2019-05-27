import Git
import AppKit

class Home: NSWindow  {
    enum State {
        case loading
        case ready
        case packed
        case create
    }
    
    class Item: NSView {
        let url: URL
        private(set) weak var check: Button.Check!
        private weak var badge: NSView!
        private weak var label: Label!
        private weak var hashtag: Label!
        
        fileprivate init(_ url: URL) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = NSColor.darker.cgColor
            
            let label = Label()
            label.attributedStringValue = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string: "\(path) ", attributes: [.font: NSFont.light(12), .foregroundColor:
                        NSColor.halo.withAlphaComponent(0.8)]))
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
            hashtag.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(hashtag)
            self.hashtag = hashtag
            
            let check = Button.Check(self, action: #selector(change))
            check.off = NSImage(named: "checkOff")
            check.on = NSImage(named: "checkOn")
            check.checked = true
            addSubview(check)
            self.check = check
            
            heightAnchor.constraint(equalToConstant: 35).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: check.leftAnchor, constant: -4).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 24).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 32).isActive = true
            check.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            check.topAnchor.constraint(equalTo: topAnchor).isActive = true
            check.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        fileprivate func status(_ current: Status) {
            switch current {
            case .deleted:
                badge.layer!.backgroundColor = NSColor.deleted.cgColor
                hashtag.stringValue = .local("Item.deleted")
            case .added:
                badge.layer!.backgroundColor = NSColor.added.cgColor
                hashtag.stringValue = .local("Item.added")
            case .modified:
                badge.layer!.backgroundColor = NSColor.modified.cgColor
                hashtag.stringValue = .local("Item.modified")
            case .untracked:
                badge.layer!.backgroundColor = NSColor.untracked.cgColor
                hashtag.stringValue = .local("Item.untracked")
            }
        }
        
        @objc private func change() {
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
    private weak var image: NSImageView!
    private weak var button: Button.Text!
    private weak var label: Label!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 400) / 2, y: (NSScreen.main!.frame.height - 400) / 2, width: 400, height: 400),
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 100)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let left = NSView()
        left.translatesAutoresizingMaskIntoConstraints = false
        left.wantsLayer = true
        left.layer!.backgroundColor = NSColor.shade.cgColor
        contentView!.addSubview(left)
        
        let top = NSView()
        top.translatesAutoresizingMaskIntoConstraints = false
        top.wantsLayer = true
        top.layer!.backgroundColor = NSColor.halo.cgColor
        contentView!.addSubview(top)
        
        let add = Button.Image(self, action: nil)
        add.image.image = NSImage(named: "add")
        
        let reset = Button.Image(self, action: nil)
        reset.image.image = NSImage(named: "reset")
        
        let cloud = Button.Image(self, action: nil)
        cloud.image.image = NSImage(named: "cloud")
        
        let log = Button.Image(self, action: nil)
        log.image.image = NSImage(named: "log")
        
        let settings = Button.Image(self, action: nil)
        settings.image.image = NSImage(named: "settings")
        
        let directory = Button.Text(app, action: #selector(app.browse))
        directory.label.stringValue = .local("Home.directory")
        directory.label.font = .systemFont(ofSize: 12, weight: .bold)
        directory.label.textColor = .black
        directory.label.alignment = .left
        contentView!.addSubview(directory)
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
        
        left.topAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        left.widthAnchor.constraint(equalToConstant: 62).isActive = true
        left.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        left.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        top.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        top.heightAnchor.constraint(equalToConstant: 40).isActive = true
        top.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        top.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        directory.topAnchor.constraint(equalTo: top.topAnchor).isActive = true
        directory.bottomAnchor.constraint(equalTo: top.bottomAnchor, constant: -2).isActive = true
        directory.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        directory.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        
        list.topAnchor.constraint(equalTo: top.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: left.rightAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
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
        label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        
        var vertical = left.topAnchor
        [add, reset, cloud, log, settings].forEach {
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
        
        switch state {
        case .loading:
            image.isHidden = false
            image.image = NSImage(named: "loading")
            button.isHidden = true
            label.isHidden = true
        case .packed:
            image.isHidden = false
            image.image = NSImage(named: "error")
            button.isHidden = false
            button.label.stringValue = .local("Home.button.packed")
            label.isHidden = false
            label.stringValue = .local("Home.label.packed")
        case .ready:
            button.isHidden = true
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
        }
        
        var bottom = list.documentView!.topAnchor
        items.forEach {
            let item = Item($0.0)
            list.documentView!.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            item.topAnchor.constraint(equalTo: bottom, constant: 2).isActive = true
            bottom = item.bottomAnchor
        }
        self.bottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottom, constant: 2)
    }
    
    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
}
