import AppKit

class Onboard: Sheet {
    @discardableResult override init() {
        super.init()
        layer!.backgroundColor = NSColor.black.cgColor
    }
    
    required init?(coder: NSCoder) { return nil }
}
