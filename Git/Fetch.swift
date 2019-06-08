import Foundation

class Fetch {
    final class Pull: Fetch {
        init(_ data: Data) throws {
            super.init()
            var lines = String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
            guard lines.count > 3, lines.removeFirst() == "001e# service=git-upload-pack", lines.removeLast() == "0000"
                else { throw Failure.Fetch.advertisement }
            lines.removeFirst()
            try lines.forEach {
                guard $0.count > 44 else { throw Failure.Fetch.advertisement }
                branch.append(String($0.dropFirst(4).prefix(40)))
            }
        }
    }
    
    final class Push: Fetch {
        init(_ data: Data) throws {
            super.init()
            var lines = String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
            guard lines.count > 2 , lines.removeFirst() == "001f# service=git-receive-pack", lines.removeLast() == "0000"
                else { throw Failure.Fetch.advertisement }
            try lines.forEach {
                guard $0.count > 48 else { throw Failure.Fetch.advertisement }
                branch.append(String($0.dropFirst(8).prefix(40)))
            }
        }
    }
    
    final var branch = [String]()
    init() { }
}
