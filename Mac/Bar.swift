import AppKit

class Bar: NSView {
    class Location: Bar {
        override init() {
            super.init()
            background.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        override func click() { (NSApp as! App).panel() }
    }
    
    class Branch: Bar {
        override init() {
            super.init()
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        override func click() { }
    }
    
    private(set) weak var label: Label!
    private var drag = CGFloat(0)
    private weak var background: NSView!
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layer!.cornerRadius = 6
        
        let background = NSView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.wantsLayer = true
        background.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.4).cgColor
        addSubview(background)
        self.background = background
        
        let label = Label()
        label.lineBreakMode = .byTruncatingMiddle
        label.font = .light(14)
        label.textColor = NSColor(white: 1, alpha: 0.6)
        addSubview(label)
        self.label = label
        
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 12).isActive = true
        label.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -12).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func click() { }

    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
    }

    override func mouseDown(with: NSEvent) {
        background.layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
    }

    override func mouseUp(with: NSEvent) {
        if drag < 2 && with.clickCount < 2 {
            click()
        }
        drag = 0
        background.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.4).cgColor
    }
}
