import AppKit

class Bar: NSControl {
    private(set) weak var label: Label!
    
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
}
