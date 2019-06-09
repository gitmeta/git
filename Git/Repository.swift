import Foundation

public final class Repository {
    public var status: (([(URL, Status)]) -> Void)?
    public let url: URL
    let state = State()
    let stage = Stage()
    let check = Check()
    let merger = Merger()
    let packer = Packer()
    
    init(_ url: URL) {
        self.url = url
        state.repository = self
        stage.repository = self
        check.repository = self
        merger.repository = self
        packer.repository = self
    }
    
    public func commit(_ files: [URL], message: String, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            self?.state.delay()
            try self?.stage.commit(files, message: message)
            self?.refresh()
        }, error: error, success: done)
    }
    
    public func pull(_ error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            guard let self = self else { return }
            self.state.delay()
            try Hub.factory.pull(self, error: error) { [weak self] in
                self?.refresh()
                DispatchQueue.main.async { done() }
            }
        }, error: error)
    }
    
    public func push(_ error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            guard let self = self else { return }
            self.state.delay()
            try Hub.factory.push(self, error: error) { [weak self] in
                self?.refresh()
                DispatchQueue.main.async { done() }
            }
        }, error: error)
    }
    
    public func log(_ result: @escaping(([Commit]) -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let url = self?.url, let result = try? History(url).result else { return [] }
            return result
        }, success: result)
    }
    
    public func reset(_ error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            self?.state.delay()
            try self?.check.reset()
            self?.refresh()
        }, error: error, success: done)
    }
    
    public func check(_ id: String, error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            self?.state.delay()
            try self?.check.check(id)
            self?.refresh()
        }, error: error, success: done)
    }
    
    public func unpack(_ error: @escaping((Error) -> Void) = { _ in }, done: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            self?.state.delay()
            try self?.packer.unpack()
            self?.refresh()
        }, error: error, success: done)
    }
    
    public func packed(_ result: @escaping((Bool) -> Void)) {
        Hub.dispatch.background({ [weak self] in self?.packer.packed ?? false }, success: result)
    }
    
    public func branch(_ result: @escaping((String) -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let url = self?.url, let branch = Hub.head.branch(url) else { return "" }
            return branch
        }, success: result)
    }
    
    public func remote(_ result: @escaping((String) -> Void)) {
        Hub.dispatch.background({ [weak self] in
            guard let url = self?.url else { return "" }
            return Hub.head.remote(url)
        }, success: result)
    }
    
    public func remote(_ remote: String, result: @escaping(() -> Void) = { }) {
        Hub.dispatch.background({ [weak self] in
            guard let url = self?.url else { return }
            try? Config(remote).save(url)
        }, success: result)
    }
    
    public func refresh() { state.refresh() }
}
