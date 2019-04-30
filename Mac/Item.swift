import Git
import AppKit

class Item: NSView {
    let url: URL
    private(set) weak var stage: Button!
    private weak var previous: Item?
    private weak var next: Item?
    private weak var badge: NSView!
    private weak var label: Label!
    private weak var path: Label!
    private weak var hashtag: Label!
    private weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
    
    init(_ url: URL) {
        self.url = url
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let path = Label(String(url.deletingLastPathComponent().path.dropFirst(App.session.url.path.count + 1)))
        path.lineBreakMode = .byTruncatingMiddle
        path.maximumNumberOfLines = 1
        path.textColor = NSColor.halo.withAlphaComponent(0.85)
        path.font = .light(14)
        path.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(path)
        self.path = path
        
        let label = Label(url.lastPathComponent)
        label.maximumNumberOfLines = 1
        label.textColor = .halo
        label.font = .bold(16)
        addSubview(label)
        self.label = label
        
        let image = NSImageView()
        image.image = NSWorkspace.shared.icon(forFile: url.path)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyDown
        addSubview(image)
        
        let badge = NSView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.wantsLayer = true
        badge.layer!.cornerRadius = 14
        addSubview(badge)
        self.badge = badge
        
        let hashtag = Label()
        hashtag.textColor = .black
        hashtag.font = .light(12)
        addSubview(hashtag)
        self.hashtag = hashtag
        
        let stage = Button(target: nil, action: nil)
        stage.setButtonType(.toggle)
        stage.state = .on
        stage.image = NSImage(named: "checkOff")
        stage.alternateImage = NSImage(named: "checkOn")
        stage.imageScaling = .scaleNone
        stage.height.constant = 40
        stage.width.constant = 40
        addSubview(stage)
        self.stage = stage
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 40).isActive = true
        image.heightAnchor.constraint(equalToConstant: 26).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        
        path.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        path.leftAnchor.constraint(equalTo: image.rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: path.rightAnchor, constant:
            path.stringValue.isEmpty ? -5 : 5).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: stage.leftAnchor, constant: -4).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 28).isActive = true
        badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
        
        hashtag.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
        
        stage.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        stage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func status(_  current: Status) {
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
    
    func remove() {
        disconnect()
        removeFromSuperview()
    }
    
    func disconnect() {
        next?.top = next?.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? superview!.topAnchor)
        previous?.next = next
        next?.previous = previous
    }
    
    func connect(_ previous: Item?) {
        top = topAnchor.constraint(equalTo: previous?.bottomAnchor ?? superview!.topAnchor)
        previous?.next?.top = previous?.next?.topAnchor.constraint(equalTo: bottomAnchor)
        next = previous?.next
        next?.previous = self
        previous?.next = self
        self.previous = previous
    }
}
