import AppKit

class Label: NSTextField {
    init(_ string: String = String()) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        stringValue = string
    }
    
    required init?(coder: NSCoder) { return nil }
}
