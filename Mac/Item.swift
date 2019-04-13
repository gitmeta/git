import AppKit

class Item: NSControl {
    weak var parent: Item?
    weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
    weak var list: List!
    let url: URL
    let indent: CGFloat
    private weak var badge: NSView!
    private weak var label: Label!
    
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
        badge.layer!.cornerRadius = 7
        badge.layer!.backgroundColor = NSColor.shade.cgColor
        addSubview(badge)
        self.badge = badge
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 42 + (indent * 20)).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 2).isActive = true
        
        badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        badge.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        badge.widthAnchor.constraint(equalToConstant: 14).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        if file.hasDirectoryPath {
            let handle = Button("", target: self, action: #selector(handle(_:)))
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
    
    override func mouseDown(with: NSEvent) {
        layer!.backgroundColor = NSColor.shade.cgColor
    }
    
    override func mouseUp(with: NSEvent) {
        layer!.backgroundColor = NSColor.clear.cgColor
    }
    
    @objc private func handle(_ handle: Button) {
        if handle.state == .on {
            list.expand(self)
        } else {
            list.collapse(self)
        }
    }
}
