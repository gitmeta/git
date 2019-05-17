import Foundation

class Extract {
    weak var repository: Repository?
    
    func reset(_ error: @escaping((Error) -> Void), done: @escaping(() -> Void)) {
        Hub.dispatch.background({ [weak self] in
            
        }, error: error, success: done)
    }
}
