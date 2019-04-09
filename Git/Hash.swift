import Foundation
import CommonCrypto

class Hash {
    private var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    
    func file(_ url: URL) throws -> String {
        return { hash(Data(("blob \($0.count)\u{0000}" + String(decoding: $0, as: UTF8.self)).utf8)) } (try Data(contentsOf: url))
    }
    
    func digest(_ data: Data) -> Data {
        _ = data.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest) }
        return Data(digest)
    }
    
    private func hash(_ data: Data) -> String {
        return digest(data).map { String(format: "%02hhx", $0) }.joined()
    }
}
