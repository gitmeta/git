import Foundation

final class Differ {
    weak var repository: Repository?
    
    func diff(_ url: URL) throws -> [(Date, String)] {
        guard
            let repository = self.repository,
            let currentId = try Hub.head.tree(repository.url).items.first(where: { $0.url.path == url.path })?.id
        else { throw Failure.Diff.unknown }
        return [(Date(), try String(decoding: Hub.content.get(currentId, url: repository.url), as: UTF8.self))]
    }
}
