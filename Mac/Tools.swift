import AppKit

class Tools: NSView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.shade.cgColor
        
        heightAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
