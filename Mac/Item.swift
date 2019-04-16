import Git
import AppKit

class Item: NSControl {
    weak var parent: Item?
    weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
    weak var list: List!
    var status = Status.none { didSet { update() } }
    let url: URL
    let indent: CGFloat
    private(set) weak var stage: Button!
    private weak var badge: NSView!
    private weak var label: Label!
    private weak var hashtag: Label!
    private var edited = false
    
    init(_ file: URL, indent: CGFloat) {
        self.url = file
        self.indent = indent
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let label = Label(file.lastPathComponent)
        label.lineBreakMode = .byTruncatingMiddle
        label.maximumNumberOfLines = 1
        label.textColor = .white
        label.font = .light(14)
        addSubview(label)
        self.label = label
        
        let image = NSImageView()
        image.image = NSWorkspace.shared.icon(forFile: file.path)
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
        
        let stage = Button(target: self, action: #selector(check))
        stage.setButtonType(.toggle)
        stage.image = NSImage(named: "checkOff")
        stage.alternateImage = NSImage(named: "checkOn")
        stage.imageScaling = .scaleNone
        stage.height.constant = 40
        stage.width.constant = 40
        stage.isHidden = true
        addSubview(stage)
        self.stage = stage
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 42 + (indent * 20)).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 2).isActive = true
        
        badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 28).isActive = true
        badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
        
        hashtag.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
        
        stage.rightAnchor.constraint(equalTo: badge.leftAnchor).isActive = true
        stage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        if file.hasDirectoryPath {
            let handle = Button(target: self, action: #selector(handle(_:)))
            handle.setButtonType(.toggle)
            handle.imageScaling = .scaleNone
            handle.image = NSImage(named: "expand")
            handle.alternateImage = NSImage(named: "collapse")
            addSubview(handle)
            
            handle.width.constant = 50
            handle.height.constant = 50
            handle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            handle.leftAnchor.constraint(equalTo: leftAnchor, constant: indent * 20).isActive = true
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    override func mouseDown(with: NSEvent) { layer!.backgroundColor = NSColor.shade.cgColor }
    override func mouseUp(with: NSEvent) { layer!.backgroundColor = NSColor.clear.cgColor }
    
    private func update() {
        switch status {
        case .none, .deleted:
            badge.layer!.backgroundColor = NSColor.clear.cgColor
            hashtag.stringValue = ""
        case .added:
            if !edited {
                stage.state = .on
            }
            badge.layer!.backgroundColor = NSColor.added.cgColor
            hashtag.stringValue = .local("Item.added")
        case .modified:
            if !edited {
                stage.state = .on
            }
            badge.layer!.backgroundColor = NSColor.modified.cgColor
            hashtag.stringValue = .local("Item.modified")
        case .untracked:
            if !edited {
                stage.state = .off
            }
            badge.layer!.backgroundColor = NSColor.untracked.cgColor
            hashtag.stringValue = .local("Item.untracked")
        }
        stage.isHidden = status == .none
    }
    
    @objc private func handle(_ handle: Button) {
        if handle.state == .on {
            list.expand(self)
        } else {
            list.collapse(self)
        }
    }
    
    @objc private func check() {
        edited = true
    }
}
