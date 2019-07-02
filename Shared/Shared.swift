import Foundation

extension String {
    static func key(_ key: String) -> String { return NSLocalizedString(key, comment: "") }
}

enum State {
    case loading
    case ready
    case packed
    case create
    case first
}
