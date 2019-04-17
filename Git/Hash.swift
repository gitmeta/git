import Foundation
import CommonCrypto

class Hash {
    private var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    
    func file(_ url: URL) -> (Data, String) {
        return {
            let packed = Data(("blob \($0.count)\u{0000}").utf8) + $0
            return (packed, hash(packed))
        } (try! Data(contentsOf: url))
    }
    
    func tree(_ data: Data) -> (Data, String) {
        let packed = Data(("tree \(data.count)\u{0000}").utf8) + data
        return (packed, hash(packed))
    }
    
    func digest(_ data: Data) -> Data {
        _ = data.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return Data(digest)
    }
    
    private func hash(_ data: Data) -> String {
        return digest(data).map { String(format: "%02hhx", $0) }.joined()
    }
}
