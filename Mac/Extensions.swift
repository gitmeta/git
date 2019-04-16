import AppKit

extension NSFont {
    class func light(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Light", size: size)! }
    class func bold(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Bold", size: size)! }
}

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let shade = #colorLiteral(red: 0.1568627451, green: 0.2156862745, blue: 0.2745098039, alpha: 1)
    static let warning = #colorLiteral(red: 1, green: 0.2901960784, blue: 0.1960784314, alpha: 1)
    static let untracked = #colorLiteral(red: 0.8874064701, green: 0.8861742914, blue: 0, alpha: 1)
    static let added = #colorLiteral(red: 0, green: 0.8377037809, blue: 0.7416605177, alpha: 1)
    static let modified = #colorLiteral(red: 0.7295059419, green: 0.5731183979, blue: 1, alpha: 1)
    static let deleted = #colorLiteral(red: 1, green: 0.3089845907, blue: 0.7107449384, alpha: 1)
}
