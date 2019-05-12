import Foundation

class Dispatch {
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    func background(_ send: @escaping(() -> Void)) {
        queue.async {
            send()
        }
    }
    
    func background(_ send: @escaping(() throws -> Void),
                       error: @escaping((Error) -> Void)) {
        queue.async {
            do {
                let result = try send()
            } catch let exception {
                DispatchQueue.main.async {
                    error(exception)
                }
            }
        }
    }
    
    func background<R>(_ send: @escaping(() -> R),
                       success: @escaping((R) -> Void)) {
        queue.async {
            let result = send()
            DispatchQueue.main.async {
                success(result)
            }
        }
    }
    
    func background<R>(_ send: @escaping(() throws -> R),
                       error: @escaping((Error) -> Void),
                       success: @escaping((R) -> Void)) {
        queue.async {
            do {
                let result = try send()
                DispatchQueue.main.async {
                    success(result)
                }
            } catch let exception {
                DispatchQueue.main.async {
                    error(exception)
                }
            }
        }
    }
}
