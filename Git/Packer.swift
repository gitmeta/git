import Foundation

final class Packer {
    weak var repository: Repository?
    
    var packed: Bool {
        if let url = repository?.url {
            if (try? FileManager.default.contentsOfDirectory(at: url.appendingPathComponent(".git/objects/pack/"), includingPropertiesForKeys: nil))?.first( where: { $0.pathExtension == "pack" }) != nil {
                return true
            }
            if FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/packed-refs").path) {
                return true
            }
        }
        return false
    }
    
    func unpack() throws {
        guard let url = repository?.url else { return }
        try Pack.pack(url).forEach {
            try $0.1.unpack(url)
            try $0.1.remove(url, id: $0.0)
        }
        try references()
        if let tree = try? Hub.head.tree(url) {
            let index = Index()
            try tree.map(index, url: url)
            index.save(url)
        }
    }
    
    private func references() throws {
        guard let url = repository?.url, FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/packed-refs").path) else { return }
        try String(decoding: try Data(contentsOf: url.appendingPathComponent(".git/packed-refs")), as: UTF8.self).components(separatedBy: "\n").forEach {
            if $0.first != "#" {
                let reference = $0.components(separatedBy: " ")
                guard reference.count >= 2 else { return }
                let location = url.appendingPathComponent(".git/" + reference[1])
                if !FileManager.default.fileExists(atPath: location.deletingLastPathComponent().path) {
                    try FileManager.default.createDirectory(at: location.deletingLastPathComponent(), withIntermediateDirectories: true)
                }
                try Data(reference[0].utf8).write(to: location, options: .atomic)
            }
        }
        try FileManager.default.removeItem(at: url.appendingPathComponent(".git/packed-refs"))
    }
}
