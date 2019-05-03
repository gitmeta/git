import Foundation

public enum Status {
    case untracked
    case added
    case modified
    case deleted
}

class State {
    weak var repository: Repository?
    var last = Date.distantPast
    let timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
    
    init() {
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler {
            Git.dispatch.background({ [weak self] in
                return self?.needs == true ? self?.list : nil
            }) { [weak self] in
                if let changes = $0 {
                    self?.repository?.status?(changes)
                }
                self?.timer.schedule(deadline: .now() + 1)
            }
        }
    }
    
    var needs: Bool {
        guard let url = repository?.url else { return false }
        if let modified = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date,
            modified > last { return true }
        return modified([url])
    }
    
    var list: [(URL, Status)] {
        guard let url = repository?.url else { return [] }
        last = Date()
        let contents = self.contents
        let index = Index(url)
        let pack = Pack.load(url)
        var tree = repository?.tree?.list(url) ?? []
        return contents.reduce(into: [(URL, Status)]()) { result, url in
            if let entries = index?.entries.filter({ $0.url == url }), !entries.isEmpty {
                let hash = Git.hash.file(url).1
                if entries.contains(where: { $0.id == hash }) {
                    if !tree.contains(where: { $0.id == hash }) {
                        if !pack.contains(where: { packed in packed.entries.contains(where: { $0.0 == hash } ) }) {
                            result.append((url, .added))
                        }
                    }
                } else {
                    result.append((url, .modified))
                }
                tree.removeAll { $0.url == url }
            } else {
                result.append((url, .untracked))
            }
        } + tree.map({ ($0.url, .deleted) })
    }
    
    func refresh() {
        last = Date.distantPast
        timer.schedule(deadline: .now() + 1)
    }
    
    private var contents: [URL] {
        guard let url = repository?.url else { return [] }
        let ignore = Ignore(url)
        return FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)?
            .map({ ($0 as! URL).resolvingSymlinksInPath() })
            .filter({ !ignore.url($0) })
            .sorted(by: { $0.path.compare($1.path, options: .caseInsensitive) != .orderedDescending }) ?? []
    }
    
    private func modified(_ urls: [URL]) -> Bool {
        var urls = urls
        guard
            !urls.isEmpty,
            let contents = try? FileManager.default.contentsOfDirectory(at: urls.first!, includingPropertiesForKeys:
                [.contentModificationDateKey])
            else { return false }
        for item in contents {
            if item.hasDirectoryPath {
                if let modified = try? item.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                    modified > last {
                    return true
                }
            }
            urls.append(item)
        }
        return modified(Array(urls.dropFirst()))
    }
}
