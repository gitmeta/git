import Foundation
@testable import Git

class MockRest: Rest {
    var _error: Error?
    var _adv: Fetch.Adv?
    
    override func adv(_ remote: String, error: @escaping ((Error) -> Void), result: @escaping ((Fetch.Adv) -> Void)) {
        if let _adv = self._adv {
            result(_adv)
        } else if let _error = self._error {
            error(_error)
        }
    }
}
