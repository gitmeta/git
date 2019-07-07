import Git
import AppKit

final class Home: Window  {
    final class Item: NSView {
        let url: URL
        private(set) weak var check: Button.Check!
        private weak var badge: NSView!
        private weak var label: Label!
        override var isOpaque: Bool { return true }
        override var wantsDefaultClipping: Bool { return false }
        
        required init?(coder: NSCoder) { return nil }
        fileprivate init(_ url: URL, status: Status) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            
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
            check.enabled = status == .deleted ? false : true
            addSubview(check)
            self.check = check
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            switch status {
            case .deleted:
                badge.layer!.backgroundColor = NSColor.deleted.cgColor
                hashtag.stringValue = .key("Home.deleted")
            case .added:
                badge.layer!.backgroundColor = NSColor.added.cgColor
                hashtag.stringValue = .key("Home.added")
            case .modified:
                badge.layer!.backgroundColor = NSColor.modified.cgColor
                hashtag.stringValue = .key("Home.modified")
            case .untracked:
                badge.layer!.backgroundColor = NSColor.untracked.cgColor
                hashtag.stringValue = .key("Home.untracked")
            }
            
            heightAnchor.constraint(equalToConstant: 46).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
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
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        override func mouseDown(with: NSEvent) {
            if with.clickCount == 1 {
                NSAnimationContext.runAnimationGroup({
                    $0.duration = 0.2
                    $0.allowsImplicitAnimation = true
                    layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.6).cgColor
                }) { }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let url = self?.url else { return }
                    if let file = app.windows.compactMap({ $0 as? File }).first(where: { $0.url == url }) {
                        file.orderFront(nil)
                    } else {
                        File(url).makeKeyAndOrderFront(nil)
                    }
                    NSAnimationContext.runAnimationGroup({
                        $0.duration = 1
                        $0.allowsImplicitAnimation = true
                        self?.layer!.backgroundColor = .clear
                    }) { }
                }
            }
        }
        
        @objc private func change() {
            app.home.recount()
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                label.alphaValue = check.checked ? 1 : 0.4
                badge.alphaValue = check.checked ? 1 : 0.3
            }) { }
        }
    }
    
    private(set) weak var directory: Button.Text!
    private(set) weak var list: NSScrollView!
    private weak var count: Label!
    private weak var image: NSImageView!
    private weak var button: Button.Yes!
    private weak var label: Label!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(600, 600, style: .resizable)
        closabe = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let directory = Button.Text(app, action: #selector(app.browse))
        directory.label.stringValue = .key("Home.directory")
        directory.label.font = .systemFont(ofSize: 12, weight: .bold)
        directory.label.textColor = .halo
        directory.label.alignment = .left
        contentView!.addSubview(directory)
        self.directory = directory
        
        let list = Scroll()
        list.flip()
        contentView!.addSubview(list)
        self.list = list
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "loading")
        contentView!.addSubview(image)
        self.image = image
        
        let button = Button.Yes(app, action: nil)
        button.isHidden = true
        contentView!.addSubview(button)
        self.button = button
        
        let label = Label()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .halo
        label.alignment = .center
        contentView!.addSubview(label)
        self.label = label
        
        let count = Label()
        count.font = .systemFont(ofSize: 12, weight: .regular)
        count.alignment = .right
        count.textColor = .halo
        contentView!.addSubview(count)
        self.count = count
        
        border.topAnchor.constraint(equalTo: self.border.bottomAnchor, constant: 2).isActive = true
        border.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 62).isActive = true
        border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        directory.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        directory.bottomAnchor.constraint(equalTo: self.border.topAnchor, constant: -3).isActive = true
        directory.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        directory.leftAnchor.constraint(equalTo: self.border.leftAnchor, constant: 82).isActive = true
        
        list.topAnchor.constraint(equalTo: self.border.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: border.rightAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        
        image.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: list.centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 38).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        button.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        
        label.centerXAnchor.constraint(equalTo: list.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
        
        count.rightAnchor.constraint(equalTo: self.border.rightAnchor, constant: -16).isActive = true
        count.centerYAnchor.constraint(equalTo: directory.centerYAnchor).isActive = true
        
        var vertical = border.topAnchor
        [("add", #selector(app.add)), ("reset", #selector(app.reset)), ("cloud", #selector(app.cloud)), ("history", #selector(app.history)), ("market", #selector(app.market)), ("settings", #selector(app.settings))].forEach {
            let button = Button.Image(app, action: $0.1)
            button.image.image = NSImage(named: $0.0)
            contentView!.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: border.leftAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.topAnchor.constraint(equalTo: vertical, constant: vertical == border.topAnchor ? 5 : 0).isActive = true
            vertical = button.bottomAnchor
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
            button.label.stringValue = .key("Home.button.packed")
            button.action = #selector(app.unpack)
            label.isHidden = false
            label.stringValue = .key("Home.label.packed")
            count.isHidden = true
        case .ready:
            button.isHidden = true
            count.isHidden = false
            label.isHidden = true
            recount()
            if items.isEmpty {
                image.isHidden = false
                image.image = NSImage(named: "updated")
            } else {
                image.isHidden = true
            }
        case .create:
            image.isHidden = false
            image.image = NSImage(named: "error")
            button.isHidden = false
            button.label.stringValue = .key("Home.button.create")
            button.action = #selector(app.create)
            label.isHidden = false
            label.stringValue = .key("Home.label.create")
            count.isHidden = true
        case .first:
            image.isHidden = false
            image.image = NSImage(named: "error")
            button.isHidden = true
            label.isHidden = false
            label.stringValue = .key("Home.label.first")
            count.isHidden = true
        }
    }
    
    override func close() {
        super.close()
        app.terminate(nil)
    }
    
    private func recount() {
        count.stringValue = {
            "\($0.filter({ $0.check.checked }).count)/\($0.count)"
        } (list.documentView!.subviews.compactMap({ $0 as? Item }))
    }
}
