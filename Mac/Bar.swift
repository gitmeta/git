import AppKit

class Bar: NSView {
    class Location: Bar {
        override init() {
            super.init()
            label.stringValue = .local("Bar.location")
            background.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        
        required init?(coder: NSCoder) { return nil }
        override func click() { App.global.panel() }
    }
    
    class Branch: Bar {
        override init() {
            super.init()
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private(set) weak var label: Label!
    private var drag = CGFloat(0)
    private weak var background: NSView!
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layer!.cornerRadius = 4
        
        let background = NSView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.wantsLayer = true
        background.layer!.backgroundColor = NSColor.halo.cgColor
        addSubview(background)
        self.background = background
        
        let label = Label()
        label.lineBreakMode = .byTruncatingMiddle
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .bold)
        addSubview(label)
        self.label = label
        
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        label.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 12).isActive = true
        label.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -12).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 23).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func click() { }

    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
    }

    override func mouseDown(with: NSEvent) {
        background.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.6).cgColor
    }

    override func mouseUp(with: NSEvent) {
        if drag < 2 && with.clickCount < 2 {
            click()
        }
        drag = 0
        background.layer!.backgroundColor = NSColor.halo.cgColor
    }
}
