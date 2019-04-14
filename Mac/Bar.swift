import AppKit

class Bar: NSControl {
    private(set) weak var label: Label!
    private var drag = CGFloat(0)
    
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layer!.cornerRadius = 5
        layer!.backgroundColor = NSColor.shade.cgColor
        
        let label = Label()
        label.font = .light(14)
        label.textColor = NSColor(white: 1, alpha: 0.6)
        addSubview(label)
        self.label = label
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 29).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
    }
    
    override func mouseDown(with: NSEvent) {
        layer!.backgroundColor = NSColor(white: 1, alpha: 0.1).cgColor
    }
    
    override func mouseUp(with: NSEvent) {
        if drag < 5 && with.clickCount < 2 {
            sendAction(#selector(App.shared.prompt), to: App.shared)
        }
        drag = 0
        layer!.backgroundColor = NSColor.shade.cgColor
    }
}
