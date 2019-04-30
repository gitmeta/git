import AppKit

class Button: NSButton {
    private(set) weak var width: NSLayoutConstraint!
    private(set) weak var height: NSLayoutConstraint!
    
    init(_ title: String? = nil, color: NSColor = .white, target: AnyObject?, action: Selector?) {
        super.init(frame: .zero)
        wantsLayer = true
        setButtonType(.momentaryChange)
        translatesAutoresizingMaskIntoConstraints = false
        isBordered = false
        width = widthAnchor.constraint(equalToConstant: 80)
        height = heightAnchor.constraint(equalToConstant: 34)
        width.isActive = true
        height.isActive = true
        self.target = target
        self.action = action
        if let title = title {
            attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.bold(14), .foregroundColor: color])
            layer!.cornerRadius = 4
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
}
