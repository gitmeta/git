import Foundation

class Blob {
    private(set) var data = Data("DIRC".utf8)
    private let hasher = Hash()
    
    func add<T>(_ number: T) { withUnsafeBytes(of: number) { data.append(contentsOf: $0.reversed()) } }
    func hash() { data.append(contentsOf: hasher.digest(data)) }
}
