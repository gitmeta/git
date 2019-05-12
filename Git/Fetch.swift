import Foundation

struct Fetch {
    struct Adv {
        var refs = [String]()
        
        init(_ data: Data) throws {
            var lines = String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
            guard lines.count > 2, lines.removeFirst() == "001e# service=git-upload-pack", lines.removeLast() == "0000"
            else { throw Failure.Fetch.advertisement }
            lines.removeFirst()
            try lines.forEach {
                guard $0.count > 44 else { throw Failure.Fetch.advertisement }
                refs.append(String($0.dropFirst(4).prefix(40)))
            }
        }
    }
}
