import Foundation

class Blob {
    private(set) var data = Data("DIRC".utf8)
    private let hasher = Hash()
    
    func add(_ date: Date) {
        add(UInt32(date.timeIntervalSince1970))
        add(UInt32(0))
    }
    
    func add(_ hash: String) {
        print("before \(data.count)")
        data.append(hash.data(using: .utf8)!)
        print("after \(data.count)")
//        Data(hash.utf8).withUnsafeBytes {
//            data.append($0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1), count: 20)
//        }
    }
    
    func name(_ string: String) { data.append(Data((string + "\u{0000}").utf8)) }
    func add<T>(_ number: T) { withUnsafeBytes(of: number) { data.append(contentsOf: $0.reversed()) } }
    func hash() { data.append(contentsOf: hasher.digest(data)) }
}
