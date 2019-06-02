import Foundation
@testable import Git

class MockRest: Rest {
    var _error: Error?
    var _fetch: Fetch?
    var _pack: Pack?
    
    override func fetch(_ remote: String, error: @escaping ((Error) -> Void), result: @escaping ((Fetch) throws -> Void)) {
        if let _fetch = self._fetch {
            do {
                try result(_fetch)
            } catch let exception {
                error(exception)
            }
        } else if let _error = self._error {
            error(_error)
        }
    }
    
    override func pack(_ remote: String, want: String, error: @escaping ((Error) -> Void), result: @escaping ((Pack) throws -> Void)) throws {
        if let _pack = self._pack {
            do {
                try result(_pack)
            } catch let exception {
                error(exception)
            }
        } else if let _error = self._error {
            error(_error)
        }
    }
}
