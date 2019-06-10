import Foundation
@testable import Git

class MockRest: Rest {
    var _error: Error?
    var _fetch: Fetch?
    var _pull: Pack?
    var onDownload: ((String) -> Void)?
    var onUpload: ((String) -> Void)?
    var onPull: ((String, String, String) -> Void)?
    var onPush: ((String, String, String, Data) -> Void)?
    
    override func download(_ remote: String, error: @escaping ((Error) -> Void), result: @escaping ((Fetch) throws -> Void)) {
        if let _fetch = self._fetch {
            do {
                try result(_fetch)
            } catch let exception {
                error(exception)
            }
        } else if let _error = self._error {
            error(_error)
        }
        onDownload?(remote)
    }
    
    override func upload(_ remote: String, error: @escaping ((Error) -> Void), result: @escaping ((Fetch) throws -> Void)) throws {
        if let _fetch = self._fetch {
            do {
                try result(_fetch)
            } catch let exception {
                error(exception)
            }
        } else if let _error = self._error {
            error(_error)
        }
        onUpload?(remote)
    }
    
    override func pull(_ remote: String, want: String, have: String = "", error: @escaping ((Error) -> Void), result: @escaping ((Pack) throws -> Void)) throws {
        if let _pull = self._pull {
            do {
                try result(_pull)
            } catch let exception {
                error(exception)
            }
        } else if let _error = self._error {
            error(_error)
        }
        onPull?(remote, want, have)
    }
    
    override func push(_ remote: String, old: String, new: String, pack: Data, error: @escaping ((Error) -> Void), done: @escaping (() throws -> Void)) throws {
        if let _error = self._error {
            error(_error)
        } else {
            try done()
        }
        onPush?(remote, old, new, pack)
    }
}
