import Foundation

final class Config {
    struct Remote {
        fileprivate(set) var url = ""
        fileprivate(set) var fetch = ""
    }
    
    struct Branch {
        fileprivate(set) var remote = ""
        fileprivate(set) var merge = ""
    }
    
    private(set) var remote = [String: Remote]()
    private(set) var branch = [String: Branch]()
    
    init(_ url: URL) throws {
        
    }
    
    var serial: String {
        var result = ""
        return result
    }
}
