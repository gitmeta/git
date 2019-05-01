import AppKit

class Bar: NSView {
    private(set) weak var label: Label!
    private var drag = CGFloat(0)
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
        layer!.cornerRadius = 4
        
        let label = Label()
        label.font = .light(14)
        label.textColor = NSColor(white: 1, alpha: 0.7)
        addSubview(label)
        self.label = label
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }

    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
    }

    override func mouseDown(with: NSEvent) {
        layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.5).cgColor
    }

    override func mouseUp(with: NSEvent) {
        if drag < 2 && with.clickCount < 2 {
            (NSApp as! App).panel()
        }
        drag = 0
        layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
    }
}
