import AppKit

class Button: NSButton {
    private(set) weak var width: NSLayoutConstraint!
    private(set) weak var height: NSLayoutConstraint!
    
    init(_ title: String, color: NSColor = .white, target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 4
        isBordered = false
        attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.bold(14), .foregroundColor: color])
        width = widthAnchor.constraint(equalToConstant: 70)
        height = heightAnchor.constraint(equalToConstant: 36)
        width.isActive = true
        height.isActive = true
        self.target = target
        self.action = action
    }
    
    required init?(coder: NSCoder) { return nil }
}
