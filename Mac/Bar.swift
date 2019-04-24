import AppKit

class Bar: NSControl {
    private(set) weak var label: Label!
    private weak var background: NSView!
    private var drag = CGFloat(0)
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let background = NSView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.wantsLayer = true
        background.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
        background.layer!.cornerRadius = 4
        addSubview(background)
        self.background = background
        
        let label = Label()
        label.font = .light(14)
        label.textColor = NSColor(white: 1, alpha: 0.8)
        background.addSubview(label)
        self.label = label
        
        background.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        background.leftAnchor.constraint(equalTo: leftAnchor, constant: 72).isActive = true
        background.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        label.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
    }
    
    override func mouseDown(with: NSEvent) {
        background.layer!.backgroundColor = NSColor.clear.cgColor
    }
    
    override func mouseUp(with: NSEvent) {
        if drag < 5 && with.clickCount < 2 {
            sendAction(#selector(App.shared.prompt), to: App.shared)
        }
        drag = 0
        background.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
    }
}
