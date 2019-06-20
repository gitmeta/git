import Foundation

public final class Hub {
    public internal(set) static var session = Session()
    static let dispatch = Dispatch()
    static let hash = Hash()
    static let press = Press()
    static let content = Content()
    static let head = Head()
    static let factory = Factory()
    
    public class func repository(_ url: URL, result: @escaping((Bool) -> Void)) {
        dispatch.background({ factory.repository(url) }, success: result)
    }
    
    public class func create(_ url: URL, error: @escaping((Error) -> Void) = { _ in }, result: @escaping((Repository) -> Void) = { _ in }) {
        dispatch.background({ try factory.create(url) }, error: error, success: result)
    }
    
    public class func open(_ url: URL, error: @escaping((Error) -> Void) = { _ in }, result: @escaping((Repository) -> Void)) {
        dispatch.background({ try factory.open(url) }, error: error, success: result)
    }
    
    public class func delete(_ repository: Repository, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        dispatch.background({ try factory.delete(repository) }, error: error, success: done)
    }
    
    public class func clone(_ remote: String, local: URL, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        dispatch.background({ try factory.clone(remote, local: local, error: error, done: done) }, error: error)
    }
}
