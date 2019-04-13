import AppKit

class Item: NSControl {
    weak var parent: Item?
    weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
    let indent: CGFloat
    private weak var label: Label!
    
    init(_ file: URL, indent: CGFloat) {
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
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 20).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor, constant: 40 + (indent * 20)).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 2).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        /*
        if document is meta.Directory {
            let tree = Button("expand", type: .toggle, target: self, action: #selector(tree(_:)))
            tree.alternateImage = NSImage(named: "collapse")
            addSubview(tree)
            
            tree.widthAnchor.constraint(equalToConstant: 50).isActive = true
            tree.topAnchor.constraint(equalTo: topAnchor).isActive = true
            tree.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            tree.leftAnchor.constraint(equalTo: leftAnchor, constant: indent * 20).isActive = true
        }*/
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func mouseDown(with: NSEvent) {
        //sendAction(#selector(List.shared.open(_:)), to: List.shared)
        layer!.backgroundColor = NSColor.shade.cgColor
    }
    
    override func mouseUp(with event: NSEvent) {
        layer!.backgroundColor = NSColor.clear.cgColor
    }

    
    @objc private func tree(_ button: Button) {
        /*if button.state == .on {
            List.shared.expand(self)
        } else {
            List.shared.collapse(self)
        }*/
    }
}
