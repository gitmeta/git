import AppKit

class Button: NSButton {
    private(set) weak var width: NSLayoutConstraint!
    private(set) weak var height: NSLayoutConstraint!
    
    init(_ title: String, color: NSColor = .white, target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 6
        isBordered = false
        attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .medium),
                                                                         .foregroundColor: color])
        self.target = target
        self.action = action
        
        width = widthAnchor.constraint(equalToConstant: 70)
        height = heightAnchor.constraint(equalToConstant: 34)
        width.isActive = true
        height.isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
