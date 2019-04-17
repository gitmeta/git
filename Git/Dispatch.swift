import Foundation

class Dispatch {
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    func background<R>(_ send: @escaping(() throws -> R),
                       error: ((Error) -> Void)? = nil,
                       success: @escaping((R) -> Void)) {
        queue.async {
            do {
                let result = try send()
                DispatchQueue.main.async {
                    success(result)
                }
            } catch let exception {
                DispatchQueue.main.async {
                    error?(exception)
                }
            }
        }
    }
}
