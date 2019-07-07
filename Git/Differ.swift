import Foundation

final class Differ {
    weak var repository: Repository?
    
    func previous(_ url: URL) throws -> (Date, Data)? {
        guard
            let repository = self.repository,
            let id = try Hub.head.tree(repository.url).list(repository.url).first(where: { $0.url.path == url.path })?.id
        else { return nil }
        if let current = try? Hub.hash.blob(Data(contentsOf: url)).1 {
            if current == id { throw Failure.Diff.unchanged }
        }
        return try ((Hub.head.commit(repository.url)).author.date, Hub.content.file(id, url: repository.url))
    }
    
    func timeline(_ url: URL) throws -> [(Date, Data)] {
        guard let repository = self.repository else { return [] }
        return try History(repository.url).result.reduce(into: { [Hub.hash.blob($0).1: (Date(), $0)] } ((try? Data(contentsOf: url)) ?? Data()), {
            guard
                let id = try Tree($1.tree, url: repository.url).items.first(where: { $0.url.path == url.path })?.id,
                $0[id] == nil
            else { return }
            $0[id] = try ($1.author.date, Hub.content.file(id, url: repository.url))
        }).values.sorted(by: { $0.0 < $1.0 })
    }
}
