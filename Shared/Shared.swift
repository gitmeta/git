import Foundation

extension String {
    static func local(_ key: String) -> String { return NSLocalizedString(key, comment: String()) }
}
