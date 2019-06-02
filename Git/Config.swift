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
    
    init(_ url: String) {
        var remote = Remote()
        remote.url = "https://" + url
        remote.fetch = "+refs/heads/*:refs/remotes/origin/*"
        var branch = Branch()
        branch.remote = "origin"
        branch.merge = "refs/heads/master"
        self.remote["origin"] = remote
        self.branch["master"] = branch
    }
    
    init(_ url: URL) throws {
        let lines = String(decoding: try Data(contentsOf: url.appendingPathComponent(".git/config")), as: UTF8.self).components(separatedBy: "\n")
        var index = 0
        while index < lines.count {
            if lines[index].prefix(7) == "[remote" {
                var remote = Remote()
                remote.url = lines[index + 1].components(separatedBy: "= ")[1]
                remote.fetch = lines[index + 2].components(separatedBy: "= ")[1]
                self.remote[lines[index].components(separatedBy: "\"")[1]] = remote
                index += 3
            } else if lines[index].prefix(7) == "[branch" {
                var branch = Branch()
                branch.remote = lines[index + 1].components(separatedBy: "= ")[1]
                branch.merge = lines[index + 2].components(separatedBy: "= ")[1]
                self.branch[lines[index].components(separatedBy: "\"")[1]] = branch
                index += 3
            } else {
                repeat {
                    index += 1
                } while index < lines.count && !lines[index].isEmpty && lines[index].first != "["
            }
        }
    }
    
    func save(_ url: URL) throws { try Data(serial.utf8).write(to: url.appendingPathComponent(".git/config"), options: .atomic) }
    
    var serial: String {
        var result = ""
        remote.forEach {
            result += """
            [remote \"\($0.0)\"]
                url = \($0.1.url)
                fetch = \($0.1.fetch)
            
            """
        }
        branch.forEach {
            result += """
            [branch \"\($0.0)\"]
                remote = \($0.1.remote)
                merge = \($0.1.merge)
            
            """
        }
        return result
    }
}
