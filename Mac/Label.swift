import AppKit

class Label: NSTextField {
    override var acceptsFirstResponder: Bool { return false }
    
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        stringValue = string
    }
    
    required init?(coder: NSCoder) { return nil }
}
