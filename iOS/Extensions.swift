import UIKit

extension UIFont {
    class func light(_ size: CGFloat) -> UIFont { return UIFont(name: "SFMono-Light", size: size)! }
    class func bold(_ size: CGFloat) -> UIFont { return UIFont(name: "SFMono-Bold", size: size)! }
}

extension UIColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let untracked = #colorLiteral(red: 0.8874064701, green: 0.8861742914, blue: 0, alpha: 1)
    static let added = #colorLiteral(red: 0, green: 0.8377037809, blue: 0.7416605177, alpha: 1)
    static let modified = #colorLiteral(red: 0.802871919, green: 0.7154764525, blue: 1, alpha: 1)
    static let deleted = #colorLiteral(red: 0.2274509804, green: 0.7803921569, blue: 0.9176470588, alpha: 1)
}
