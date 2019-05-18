import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Light", size: size)! }
    class func bold(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Bold", size: size)! }
}

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let shade = #colorLiteral(red: 0.1058823529, green: 0.1490196078, blue: 0.1882352941, alpha: 1)
    static let untracked = #colorLiteral(red: 0.8874064701, green: 0.8861742914, blue: 0, alpha: 1)
    static let added = #colorLiteral(red: 0, green: 0.8377037809, blue: 0.7416605177, alpha: 1)
    static let modified = #colorLiteral(red: 0.802871919, green: 0.7154764525, blue: 1, alpha: 1)
    static let deleted = #colorLiteral(red: 1, green: 0.4639141682, blue: 0.834259463, alpha: 1)
}

class Flipped: NSView { override var isFlipped: Bool { return true } }
