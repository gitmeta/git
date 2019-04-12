import AppKit

class Bar: NSControl {
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        layer!.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 25).isActive = true
        layer!.backgroundColor = NSColor.shade.cgColor
    }
    
    required init?(coder: NSCoder) { return nil }
}
