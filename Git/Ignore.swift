import Foundation

final class Ignore {
    private var contains = ["/.git/"]
    private var suffix = ["/.git"]
    
    init(_ url: URL) {
        guard let data = try? Data(contentsOf: url.appendingPathComponent(".gitignore")) else { return }
        String(decoding: data, as: UTF8.self).components(separatedBy: "\n").filter({ !$0.isEmpty }).forEach {
            switch $0.first {
            case "*":
                suffix.append(String($0.dropFirst()))
                contains.append({ $0.last == "/" ? $0 : $0 + "/" } (String($0.dropFirst())))
            case "/": suffix.append($0)
            default: suffix.append("/" + $0)
            }
            switch $0.last {
            case "*": contains.append({ $0.first == "/" ? $0 : "/" + $0 } (String($0.dropLast())))
            case "/": contains.append($0.first == "/" ? $0 : "/" + $0)
            default: contains.append(($0.first == "/" ? $0 : "/" + $0) + "/")
            }
        }
    }
    
    func url(_ url: URL) -> Bool {
        guard
            !url.hasDirectoryPath,
            !contains.contains(where: { url.path.contains($0) }),
            !suffix.contains(where: { url.path.hasSuffix($0) })
        else { return true }
        return false
    }
}
