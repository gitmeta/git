import AppKit

class Storage: NSTextStorage {
    override var string: String { return storage.string }
    private let light = NSFont.light(18)
    private let bold = NSFont.bold(18)
    private let storage = NSTextStorage()
    
    override func attributes(at: Int, effectiveRange: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        return storage.attributes(at: at, effectiveRange: effectiveRange)
    }
    
    override func replaceCharacters(in range: NSRange, with: String) {
        storage.replaceCharacters(in: range, with: with)
        edited(.editedCharacters, range: range, changeInLength: with.count - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
    }
}
