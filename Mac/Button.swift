import AppKit

class Button: NSButton {
    private(set) weak var width: NSLayoutConstraint!
    private(set) weak var height: NSLayoutConstraint!
    
    init(_ title: String, target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.shade.cgColor
        layer!.cornerRadius = 6
        isBordered = false
        attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .medium),
                                                                         .foregroundColor: NSColor.white])
        self.target = target
        self.action = action
        
        width = widthAnchor.constraint(equalToConstant: 70)
        height = heightAnchor.constraint(equalToConstant: 30)
        width.isActive = true
        height.isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
