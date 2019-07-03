import Foundation

final class Differ {
    weak var repository: Repository?
    
    func previous(_ url: URL) throws -> (Date, Data)? {
        guard
            let repository = self.repository,
            let id = try Hub.head.tree(repository.url).items.first(where: { $0.url.path == url.path })?.id
        else { return nil }
        let current = try Hub.hash.blob(Data(contentsOf: url)).1
        if current == id { throw Failure.Diff.unchanged }
        return try ((Hub.head.commit(repository.url)).author.date, Hub.content.file(id, url: repository.url))
    }
}
