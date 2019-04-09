import Foundation

class Blob {
    private(set) var data = Data("DIRC".utf8)
    private let hasher = Hash()
    private static let map = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
        0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
        0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ] as [UInt8]
    
    func date(_ date: Date) {
        add(UInt32(date.timeIntervalSince1970))
        add(UInt32(0))
    }
    
    func hex(_ string: String) {
        data.append(contentsOf: string.utf8.reduce(into: ([UInt8](), [UInt8]())) {
            $0.0.append(Blob.map[Int($1 & 0x1F ^ 0x10)])
            if $0.0.count == 2 {
                $0.1.append($0.0[0] << 4 | $0.0[1])
                $0.0 = []
            }
            }.1)
    }
    
    func name(_ string: String) { data.append(Data((string + "\u{0000}").utf8)) }
    func add<T>(_ number: T) { withUnsafeBytes(of: number) { data.append(contentsOf: $0.reversed()) } }
    func hash() { data.append(contentsOf: hasher.digest(data)) }
}
